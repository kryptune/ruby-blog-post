class TransactionalEmailJob < ApplicationJob
  queue_as :mailers

  retry_on StandardError, wait: :exponentially_longer, attempts: 5
  
  def perform(user_id, type)
    user = User.find(user_id)
    case type
    when :password_reset
      UserMailer.password_reset(user).deliver_now
    when :verification
      UserMailer.verification_email(user).deliver_now
    end
  end
end
