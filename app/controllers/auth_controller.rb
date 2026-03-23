class AuthController < ApplicationController
  skip_before_action :authorize, only: [:login, :create]

  def login; end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      access_token = JWT.encode(
        { user_id: user.id, exp: 1.minutes.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      refresh_token = JWT.encode(
        { user_id: user.id, exp: 3.minutes.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      cookies.signed[:jwt] = { value: access_token, httponly: true }
      cookies.signed[:refresh_jwt] = { value: refresh_token, httponly: true }

      redirect_to blog_posts_path, notice: "Logged in successfully!"
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "flash",
            partial: "shared/flash",
            locals: { alert: "Invalid credentials" }
          )
        end
        format.html do
          flash.now[:alert] = "Invalid credentials"
          render :login
        end
      end
    end
  end

  def logout
    cookies.delete(:jwt) 
    cookies.delete(:refresh_jwt)
    flash[:notice] = "Logged out successfully"
    redirect_to login_path
  end

    private

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end
end