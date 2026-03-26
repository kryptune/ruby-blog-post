
    class Api::V1::UsersController < ApplicationController
      skip_before_action :authorize, only: [:register, :create, :verify]
      include RateLimitable, RenderFlash, TokenManager
      # before_action only: [:create] do
      #   check_rate_limit(limit: 3, window: 3600)    # register
      # end

      def register; end
      
      def create 
        user = User.new(user_params)
        if user.save
          save_tokens(user)
          deliver_email_to(user)
          redirect_to api_v1_login_path, notice: "Account created, verify your email now!"
        else
          render_flash(user.errors.full_messages.join(", "), api_v1_register_path)
        end

      end

      def verify
        user = User.find_by(verification_token: params[:token])
        if user&.update(email_verified: true, verification_token: nil)
          render_flash("Email verified successfully!", blog_posts_path, type: :notice)
        else
          render_flash("Invalid or expired verification link.", api_v1_login_path)            
        end
      end

      private

      def user_params
        params.permit(:username, :email, :password, :password_confirmation, :terms)
      end

      def deliver_email_to(user)
        UserMailer.verification_email(user).deliver_now
      end

    end

