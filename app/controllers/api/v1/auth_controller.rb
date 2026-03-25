
class Api::V1::AuthController < ApplicationController
  skip_before_action :authorize, only: [:create, :login]
  include RateLimitable, RenderFlash, TokenManager, RespondToFormat
  before_action only: [:create] do
    check_rate_limit(limit: 5, window: 60)      # login
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.email_verified
        access_token = save_tokens(user)
        payload = json_opts(user, access_token )
        respond_to_format(payload, blog_posts_path, "Welcome back!", type: :notice)
      else
        render_flash("Please verify your email before logging in.", api_v1_login_path, status: :unauthorized ) and return
      end
    else
      render_flash("Invalid Credentials.", api_v1_login_path, status: :forbidden ) and return
    end
  end

  def logout
    remove_tokens(current_user)
    redirect_to api_v1_login_path, notice: "Logged out successfully"
  end

  private

  def json_opts(user, access_token)
    { 
        json: { 
          message: "Logged in successfully", 
          access_token: access_token, 
          user: user.as_json(only: [:id, :email, :name]) 
        }, 
        status: :ok 
    }
  end

end
