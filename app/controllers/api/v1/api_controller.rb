class Api::V1::ApiController < ActionController::API
  include Api::ApiTokenManager, Api::Errorable, RateLimitable, UserTimeZone
  helper_method :current_user, :logged_in?
  around_action :with_user_time_zone

  def current_user
    @current_user ||= find_user_from_token
  end

  def logged_in?
    current_user.present?
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end
  
end