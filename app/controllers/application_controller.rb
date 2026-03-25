class ApplicationController < ActionController::Base
  include SignCookies, RenderFlash, RefreshAccessToken, DecodeToken
  before_action :authorize
  helper_method :current_user, :logged_in?

  private
  
  def authorize
    header = cookies.signed[:jwt] || extract_bearer_token
    unless header
      respond_to do |format|
        format.json { head :unauthorized }
        format.html { redirect_to api_v1_login_path, alert: "Please log in first" }
      end
      return
    end

    begin
      decoded = decode_token(header)
      @current_user = User.find(decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      decoded = decode_token(header, skip_verification: false)
      user = User.find(decoded[0]["user_id"])
      refresh_token = cookies.signed[:refresh_jwt] || user.refresh_token
      if refresh_token
        refresh_access_token(user, refresh_token)
      else
        render_flash("No refresh token found", api_v1_login_path, status: :unauthorized) and return
      end
    rescue JWT::DecodeError
      render_flash("Invalid token", api_v1_login_path, status: :unauthorized) and return
    end
  end

  def extract_bearer_token(header: "Authorization")
    token = request.headers[header]
    token&.start_with?("Bearer ") ? token.split(" ").last : nil
  end

  def current_user
    @current_user
  end

  def logged_in?
    !!current_user
  end


end