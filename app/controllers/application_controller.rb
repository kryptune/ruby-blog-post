class ApplicationController < ActionController::Base
  include RenderFlash, SessionManager, UserTimeZone
  helper_method :current_user, :logged_in?
  around_action :with_user_time_zone

  private

  def current_user
    @current_user ||= find_user_from_session
  end

  def logged_in?
    current_user.present?
  end





end