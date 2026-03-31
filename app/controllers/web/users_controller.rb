
    class Web::UsersController < ApplicationController
      include RateLimitable
      before_action :check_rate_limit, only: [:create]

      def register; end

      def create 
        result = RegisterUser.call(user_params)
        if result.success?
          deliver_email_to(result.user,  web_verify_url(token: result.user.verification_token))
          redirect_to web_login_path, notice:"Account created, verify your email now!"
        else
          render_flash(result.message, web_register_path)
        end
      end

      def verify
        user = User.find_by(verification_token: params[:token])
        if user&.update(email_verified: true, verification_token: nil)
          save_session(user)
          render_flash("Email verified successfully!", blog_posts_path, type: :notice)
        else
          render_flash("Invalid or expired verification link.", web_login_path)            
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

