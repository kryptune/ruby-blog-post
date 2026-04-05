class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @url  = web_verify_url(token: @user.verification_token)
    mail(to: @user.email, subject: 'Verify your email')
  end

  def password_reset(user)
    @user = user
    #TODO
    mail(to: @user.email, subject: 'Reset your password')
  end
end
