class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @url  = web_verify_url(token: @user.verification_token)
    mail(to: @user.email, subject: 'Verify your email')
  end
end
