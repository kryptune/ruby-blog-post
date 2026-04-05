
class Api::V1::AuthController < Api::V1::ApiController
  include SessionManager, Api::Authenticate
  before_action only: [:create] do
    check_rate_limit(:login)    
  end
  before_action :authenticate, only: [:logout_all]

  def login; end

  def create
    result = AuthenticateUser.call(auth_params)
    if result.success?
      access_token, refresh_token = generate_tokens(result.user)
      save_session(result.user, refresh_token)
      render json_opts("Logged in successfully", access_token, refresh_token, user: result.user)
    else
      render json: { error: result.message }, status: :forbidden
    end
  end

  def refresh
    result = RefreshToken.call
    if result.success?
      render json_opts("Token refreshed", result.new_access_token, user: result.user )
    else
      render json: { error: result.message }, status: :unauthorized
    end
  end

  def logout
    result = LogoutUser.call(refresh_token: params[:refresh_token], web: false)
    if result.success?
      render json: {message: result.message}, status: :ok
    else
      render json: { error: result.message }, status: :unauthorized
    end
  end

  def logout_all
    result = LogoutUser.call(user: current_user, logout_all: true)
    if result.success?
      render json: { message: result.message }, status: :ok
    else
      render json: { error: result.message }, status: :unauthorized
    end
  end

    private

  def auth_params
    params.permit(:email, :password)
  end

end
