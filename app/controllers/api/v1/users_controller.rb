module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :authorize, only: [:register, :create, :verify]
      include RateLimitable, RenderFlash, EncodeToken, SignCookies
      # before_action only: [:create] do
      #   check_rate_limit(limit: 3, window: 3600)    # register
      # end

      def register; end
      
      def create 
        @user = User.new(user_params)
        if @user.save
          access_token = encode_token({user_id: @user.id, exp: 10.minutes.from_now.to_i})
          refresh_exp = (params[:remember_me] == "1" ? 30 : 7).days.from_now.to_i
          refresh_token = encode_token({user_id: @user.id, exp: refresh_exp})
          sign_cookies(access_token, refresh_token)
          @user.update(refresh_token: refresh_token)
          UserMailer.verification_email(@user).deliver_now
          redirect_to api_v1_login_path, notice: "Account created, verify your email now!"
          return
        else
          render_flash(@user.errors.full_messages.join(", "), api_v1_register_path) and return
        end

      end

      def verify
        user = User.find_by(verification_token: params[:token])
        if user
          if user.update(email_verified: true, verification_token: nil)
            render_flash("Email verified successfully!", blog_posts_path, type: :notice) and return
          else
            render_flash("Verification failed: #{user.errors.full_messages.join(', ')}", api_v1_login_path) and return            
          end
        else
          render_flash("Invalid or expired verification link.",  api_v1_login_path) and return
        end
      end

      private

      def user_params
        params.permit(:username, :email, :password, :password_confirmation, :terms)
      end

    end
  end
end
