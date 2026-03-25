module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize, only: [:create, :login]
      include RateLimitable, RenderFlash, SignCookies, EncodeToken, RemoveTokens
      before_action only: [:create] do
        check_rate_limit(limit: 5, window: 60)      # login
      end

      def create
        user = User.find_by(email: params[:email])
        if user&.authenticate(params[:password])
          if user.email_verified
            create_tokens
            respond_to do |format|
              format.json { render json: { message: "Logged in successfully", access_token: @access_token, user: user.as_json(only: [:id, :email, :name]) }, status: :ok }
              format.html { redirect_to blog_posts_path, notice: "Logged in successfully!" }
            end
          else
            render_flash("Please verify your email before logging in.", api_v1_login_path, status: :unauthorized ) and return
          end
        else
          render_flash("Invalid Credentials.", api_v1_login_path, status: :forbidden ) and return
        end
      end

      def logout
        remove_tokens
        redirect_to api_v1_login_path, notice: "Logged out successfully"
      end

      private

      def create_tokens
        @access_token = encode_token({user_id: user.id, exp: 10.minutes.from_now.to_i})
        refresh_exp = (params[:remember_me] == "1" ? 30 : 7).days.from_now.to_i
        @refresh_token = encode_token({user_id: user.id, exp: refresh_exp})
        sign_cookies(@access_token, @refresh_token)
        user.update(refresh_token: @refresh_token)
      end


    end
  end
end