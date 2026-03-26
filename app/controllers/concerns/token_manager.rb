module TokenManager
  extend ActiveSupport::Concern

  def generate_access_token(user)
    encode_token({ user_id: user.id, exp: 10.minutes.from_now.to_i })
  end

  def generate_refresh_token(user)
    exp = (params[:remember_me] == "1" ? 30 : 7).days.from_now.to_i
    encode_token({ user_id: user.id, exp: exp })
  end

  def save_tokens(user)
    access_token  = generate_access_token(user)
    refresh_token = generate_refresh_token(user)

    sign_cookies(access_token, refresh_token)
    user.update!(refresh_token: refresh_token)
    access_token
  end

  def encode_token(payload)
    JWT.encode(payload, ENV['JWT_SECRET_KEY'], 'HS256')
  end

  def decode_token(header_token, verification: true)
    JWT.decode(header_token, ENV['JWT_SECRET_KEY'], verification, algorithm: 'HS256')
  end

  def sign_cookies(access, refresh = nil)
    cookies_opts = {
          httponly: true,   # Prevents JavaScript access (XSS protection)
          secure: Rails.env.production?, # Only send over HTTPS in production
          same_site: Rails.env.production? ? :strict : :lax  # strict in prod, lax in dev
          }
    cookies.signed[:jwt] = cookies_opts.merge(value: access)
    cookies.signed[:refresh_jwt] = cookies_opts.merge(value: refresh) if refresh
  end

  def remove_tokens(user)
    user.update(refresh_token: nil)  # clear from DB
    cookies.delete(:refresh_jwt)
    cookies.delete(:jwt)   
  end

  def refresh_access_token(user, refresh_token)
    begin
      decode_token(refresh_token)
      payload =  { user_id: user.id, exp: 10.minutes.from_now.to_i }
      new_access_token = encode_token(payload)
      sign_cookies(new_access_token)                                # sets cookie → browser uses it, mobile ignores it
      response.set_header("X-New-Access-Token", new_access_token) if request.format.json?   # sets header → mobile uses it, browser ignores it
      @current_user = user
    rescue JWT::ExpiredSignature
      remove_tokens(user)
      render_flash("Session expired, please log in again", api_v1_login_path, status: :unauthorized)
    rescue JWT::DecodeError
      remove_tokens(user)
      render_flash("Invalid refresh token", api_v1_login_path, status: :unauthorized)
    end
  end

  def get_refresh_token(header_token)
    decoded = decode_token(header_token, verification: false)
    user = User.find(decoded[0]["user_id"])
    refresh_token = cookies.signed[:refresh_jwt] || user.refresh_token
    [user, refresh_token]
  end

  def find_user_from_token
    token = extract_bearer_token || cookies.signed[:jwt]
    return nil unless token
    begin
      decoded = decode_token(token) 
      User.find(decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      handle_refresh(header_token: token)
    rescue JWT::DecodeError
      render_flash("Invalid token", api_v1_login_path, status: :unauthorized) and return
    end
  end

  def handle_refresh(header_token: nil)
    user, refresh_token = get_refresh_token(header_token)
    if refresh_token
      refresh_access_token(user, refresh_token)
    else
      render_flash("No refresh token found", api_v1_login_path, status: :unauthorized) and return
    end
  end
  
  def get_header_token
    cookies.signed[:jwt] || extract_bearer_token
  end

  private

  def extract_bearer_token(header: "Authorization")
    token = request.headers[header]
    token&.start_with?("Bearer ") ? token.split(" ").last : nil
  end
end