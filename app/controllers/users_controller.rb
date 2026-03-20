class UsersController < ApplicationController
  skip_before_action :authorize, only: [:register, :create]

  def register; end
  
  def create 
    @user = User.new(user_params)
    if @user.save
      access_token = JWT.encode(
        { user_id: user.id, exp: 5.minutes.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      refresh_token = JWT.encode(
        { user_id: user.id, exp: 7.days.from_now.to_i },
        Rails.application.secret_key_base, 'HS256'
      )

      cookies.signed[:jwt] = { value: access_token, httponly: true }
      cookies.signed[:refresh_jwt] = { value: refresh_token, httponly: true }
      redirect_to blog_posts_path, notice: "Account created successfully!"

    else
      render_flash(@user.errors.full_messages.join(", "))
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
