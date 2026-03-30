class Api::V1::ApiController < ActionController::API
  include Api::ApiTokenManager, Api::Errorable, RateLimitable
  helper_method :current_user

  def current_user
    @current_user ||= find_user_from_token
  end

end