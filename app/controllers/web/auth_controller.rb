
class Web::AuthController < ApplicationController
  skip_before_action :session_logged_in?, only: [:create, :login]
  include RateLimitable
  before_action only: [:create] do
    check_rate_limit(limit: 5, window: 60)      # login
  end

  def login; end

  # def refresh
  #   refresh_token = get_refresh_token
  #   return render_flash("No refresh token provided", web_login_path) if refresh_token.nil?
  #   user = decode_user_from_token(refresh_token)
  #   if user.sessions.active.find_by(refresh_token: refresh_token).present?
  #       refresh_access_token(user, refresh_token)
  #   else
  #     render_flash("No refresh token found", web_login_path)
  #   end
  # end


  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.email_verified
        save_session(user)
        redirect_to blog_posts_path, notice: "Welcome back!"
      else
        render_flash("Please verify your email before logging in.", web_login_path )
      end
    else
      render_flash("Invalid Credentials.", web_login_path)
    end
  end

  def logout
    remove_tokens(current_user)
    redirect_to web_login_path, notice: "Logged out successfully"
  end

  def logout_all
    remove_tokens(current_user)
    current_user.sessions.destroy_all
    redirect_to web_login_path, notice: "Logged out from all devices."
  end

end
