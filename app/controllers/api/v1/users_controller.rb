class Api::V1::UsersController < Api::V1::ApiController
  before_action only: [:create] do
    check_rate_limit(:register)     # create post
  end

  def create 
    result = RegisterUser.call(user_params)
    if result.success?
      deliver_email_to(result.user_id)
      render json: { message: "Account created, verify your email now!" }, status: :ok
    else
      render json: { message: result.message }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:username, :email, :password, :password_confirmation, :terms)
  end

  def deliver_email_to(user_id)
    TransactionalEmailJob.perform_later(user_id, :verification)  
  end

