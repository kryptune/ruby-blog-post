
    class Api::V1::UsersController < Api::V1::ApiController
      before_action only: [:create] do
        check_rate_limit(limit: 3, window: 3600)    # register
      end
      
      def create 
        user = User.new(user_params)
        if user.save
          render json: { message: "Account created, verify your email now!" }, status: :ok
          deliver_email_to(user)
        else
          render json: { message: "#{user.errors.full_messages.join(", ")}" }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:username, :email, :password, :password_confirmation, :terms)
      end

      def deliver_email_to(user)
        UserMailer.verification_email(user).deliver_later
      end

    end

