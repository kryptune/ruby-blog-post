class UsersController < ApplicationController
  skip_before_action :authorize, only: [:register, :create]
  include RateLimitable
  before_action only: [:create] do
    check_rate_limit(limit: 3, window: 3600)    # register
  end

  def register; end
  
  def create 
    @user = User.new(user_params)
    if @user.save
      access_token = JWT.encode(
        { user_id: @user.id, exp: 10.minutes.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      refresh_token = JWT.encode(
        { user_id: @user.id, exp: 7.days.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      cookies.signed[:jwt] = { value: access_token,         
        httponly: true,   # Prevents JavaScript access (XSS protection)
        secure: Rails.env.production?, # Only send over HTTPS in production
        same_site: :strict # Prevents CSRF by blocking cross-site requests
      }
      cookies.signed[:refresh_jwt] = { value: refresh_token,         
        httponly: true,   # Prevents JavaScript access (XSS protection)
        secure: Rails.env.production?, # Only send over HTTPS in production
        same_site: :strict # Prevents CSRF by blocking cross-site requests
      }
      UserMailer.verification_email(@user).deliver_later
      redirect_to login_path, notice: "Account created, verify your email now!"

    else
      render_flash(@user.errors.full_messages.join(", "))
    end

  end

  def verify
    user = User.find_by(verification_token: params[:token])
    if user
      user.update(email_verified: true, verification_token: nil)
      redirect_to root_path, notice: "Email verified successfully!"
    else
      redirect_to root_path, alert: "Invalid or expired verification link."
    end
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation, :terms)
  end


  def render_flash(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "flash",
          partial: "shared/flash",
          locals: { alert: message }
        )
      end
      format.html do
        flash[:alert] = message
        redirect_to register_path
      end
    end
  end

  def encode_token(payload)
    JWT.encode(payload, Rails.application.secret_key_base, 'HS256')
  end

end
