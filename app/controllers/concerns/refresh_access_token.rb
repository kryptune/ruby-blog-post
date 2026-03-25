module RefreshAccessToken
  extend ActiveSupport::Concern
  include DecodeToken, RemoveTokens
  def refresh_access_token(user, refresh_token)
    begin
      decode_token(refresh_token)
      new_access_token = JWT.encode(
        { user_id: user.id, exp: 10.minutes.from_now.to_i },
        ENV['JWT_SECRET_KEY'], 'HS256'
      )
      sign_cookies(new_access_token)                                # sets cookie → browser uses it, mobile ignores it
      response.set_header("X-New-Access-Token", new_access_token)   # sets header → mobile uses it, browser ignores it
      @current_user = user
    rescue JWT::ExpiredSignature
      remove_tokens
      render_flash("Session expired, please log in again", api_v1_login_path, status: :unauthorized) and return
    rescue JWT::DecodeError
      remove_tokens
      render_flash("Invalid refresh token", api_v1_login_path, status: :unauthorized) and return
    end
  end

end