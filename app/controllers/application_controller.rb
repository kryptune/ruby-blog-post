class ApplicationController < ActionController::Base
  include RenderFlash, SessionManager
  helper_method :current_user, :logged_in?
  around_action :with_user_time_zone

  private

  def current_user
    @current_user ||= find_user_from_session
  end

  def logged_in?
    current_user.present?
  end

  def with_user_time_zone(&block)
    # change 'Asia/Manila' to current_user.time_zone to make it dynamic
    Time.use_zone('Asia/Manila', &block)
  end




end