# class ApplicationController < ActionController::Base
#   # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
#   allow_browser versions: :modern

#   # Changes to the importmap will invalidate the etag for HTML responses
#   stale_when_importmap_changes
# end


class ApplicationController < ActionController::Base
  before_action :authorize
  helper_method :current_user, :logged_in?

  private
  
  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  
  def authorize
    header = cookies.signed[:jwt] || request.headers["Authorization"]
    return head :unauthorized unless header

    begin
      decoded = JWT.decode(header, Rails.application.secret_key_base, true, algorithm: 'HS256')
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      # Access token expired → try refresh
      refresh_token = cookies.signed[:refresh_jwt]
      if refresh_token
        begin
          decoded_refresh = JWT.decode(refresh_token, Rails.application.secret_key_base, true, algorithm: 'HS256')
          user = User.find(decoded_refresh[0]["user_id"])

          # Issue new access token
          new_access_token = JWT.encode(
            { user_id: user.id, exp: 1.minutes.from_now.to_i },
            Rails.application.secret_key_base, 'HS256'
          )
          cookies.signed[:jwt] = { value: new_access_token, httponly: true }
          @current_user = user
        rescue JWT::ExpiredSignature
          # Refresh token also expired → force login
          redirect_to login_path, alert: "Session expired, please log in again"
          return
        rescue JWT::DecodeError
          redirect_to login_path, alert: "Invalid refresh token"
          return
        end
      else
        redirect_to login_path, alert: "No refresh token found"
        return
      end
    rescue JWT::DecodeError
      redirect_to login_path, alert: "Invalid token"
      return
    end
  end



  def current_user
    @current_user ||= begin
      decoded = JWT.decode(cookies.signed[:jwt], Rails.application.secret_key_base, true, algorithm: 'HS256')
      User.find(decoded[0]["user_id"])
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end

  def logged_in?
    !!current_user
  end
end