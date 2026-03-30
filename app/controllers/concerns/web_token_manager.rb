module WebTokenManager


  def save_tokens(user)
    access_token , refresh_token  = generate_tokens(user)
    sign_cookies(access_token, refresh_token)
    [access_token , refresh_token]
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
    refresh_token = get_refresh_token
    user&.sessions&.find_by(session_token: refresh_token)&.destroy
    cookies.delete(:refresh_jwt)
    cookies.delete(:jwt)   
  end

  def get_refresh_token
    cookies.signed[:refresh_jwt]
  end


  def refresh_access_token(user, refresh_token)
    begin
      decoded = decode_token(refresh_token)
      payload =  { user_id: user.id, exp: 10.minutes.from_now.to_i }
      new_access_token = encode_token(payload)
      sign_cookies(new_access_token)                                # sets cookie → browser uses it, mobile ignores it
      response.set_header("X-New-Access-Token", new_access_token) if request.format.json?   # sets header → mobile uses it, browser ignores it
      @current_user = User.find_by(id: decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      remove_tokens(user)
      render_flash("Session expired, please log in again", web_login_path)
    rescue JWT::DecodeError
      remove_tokens(user)
      render_flash("Invalid refresh token", web_login_path)
    end
  end

  def find_user_from_token
    token = extract_bearer_token
    return nil unless token
    begin
      decoded = decode_token(token)
      @current_user = User.find_by(id: decoded[0]["user_id"])
      @current_user
    rescue JWT::ExpiredSignature
      handle_refresh
      @current_user
    rescue JWT::DecodeError
      render_flash("Invalid token", web_login_path)
      nil
    end
  end

  def decode_user_from_token(token)
    decoded = decode_token(token, verification: false) 
    user_id = decoded[0]["user_id"]
    User.find_by(id: user_id)
  end
  




 



end