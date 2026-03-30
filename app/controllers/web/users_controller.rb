
    class Web::UsersController < ApplicationController
      skip_before_action only: [:register, :create, :verify]
      include RateLimitable
      # before_action only: [:create] do
      #   check_rate_limit(limit: 3, window: 3600)    # register
      # end

      def register; end
      
      def create 
        user = User.new(user_params)
        if user.save
          deliver_email_to(user)
          redirect_to web_login_path, notice:"Account created, verify your email now!"
        else
          render_flash(user.errors.full_messages.join(", "), web_register_path)
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

