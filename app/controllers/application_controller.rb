class ApplicationController < ActionController::Base
  include RenderFlash, TokenManager, RespondToFormat
  before_action :authorize
  helper_method :current_user, :logged_in?
  around_action :with_user_time_zone

  private
  
  def authorize
    header_token = get_header_token
    unless header_token
      json_opts = { status: :unauthorized }
      respond_to_format(json_opts, api_v1_login_path, "Please log in.")
      return
    end

    begin
      decoded = decode_token(header_token)
      user = User.find(decoded[0]["user_id"])
    rescue JWT::ExpiredSignature
      handle_refresh(header_token: header_token)
    rescue JWT::DecodeError
      render_flash("Invalid token", api_v1_login_path, status: :unauthorized) and return
    end
  end

  def current_user
    @current_user ||= find_user_from_token
  end

  def logged_in?
    current_user.present?
  end

  def with_user_time_zone(&block)
    # You can eventually make this dynamic based on current_user.time_zone
    Time.use_zone('Asia/Manila', &block)
  end

end