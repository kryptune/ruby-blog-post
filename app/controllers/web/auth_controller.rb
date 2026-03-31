class Web::AuthController < ApplicationController
  include RateLimitable
  before_action :check_rate_limit, only: [:create]
  before_action :session_logged_in?, only: [:logout, :logout_all]

  def login; end

  def create
    result =  AuthenticateUser.call(auth_params)
    if result.success?
      save_session(result.user)
      redirect_to blog_posts_path, notice: "Welcome back!"
    else
      render_flash(result.message, web_login_path)
    end
  end

  def logout
    result = LogoutUser.call(user: current_user, web: true)
    if result.success?
      remove_tokens(current_user)
      redirect_to web_login_path, notice: result.message
    else
      render_flash(result.message, web_login_path)
    end
  end

  def logout_all
    result = LogoutUser.call(user: current_user, logout_all: true)
    if result.success?
      remove_tokens(current_user)
      redirect_to web_login_path, notice: "Logged out from all devices."
    else
      render_flash(result.message, web_login_path)
    end
  end

  private

    def auth_params
      params.permit(:email, :password)
    end

end
