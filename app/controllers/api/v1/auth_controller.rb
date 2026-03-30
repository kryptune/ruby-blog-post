
class Api::V1::AuthController < Api::V1::ApiController
  include SessionManager, Authenticate
  before_action only: [:create] do
    check_rate_limit(limit: 5, window: 60)      # login
  end
  before_action :authenticate, only: [:logout_all]

  def login; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.email_verified
        access_token, refresh_token = generate_tokens(user)
        save_session(user, refresh_token)
        render json_opts("Logged in successfully", access_token, refresh_token, user: user)
      else
        render json: { error: "Please verify your email before logging in." }, status: :unauthorized
      end
    else
      render json: { error: "Invalid Credentials." }, status: :forbidden
    end
  end

  def refresh
    token = get_header_token
    session = Session.active.find_by(session_token: token)
    if session
      user = session.user
      session.touch(:updated_at) 
      new_access_token = encode_token({ user_id: user.id, exp: 10.minutes.from_now.to_i }) 
      render json_opts("Token refreshed", new_access_token, user: user )
    else
      render json: { error: "Session expired or invalid" }, status: :unauthorized
    end
  end

  def logout
    token = params[:refresh_token]
    Session.find_by(session_token: token)&.destroy
    render json: { message: "Logged out of this device." }, status: :ok
  end

  def logout_all
    current_user.sessions.destroy_all
    render json: { message: "Logged out of all devices." }, status: :ok
  end


end
