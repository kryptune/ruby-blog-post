class AuthenticateUser
  include Interactor

  def call 
    user = User.find_by(email: context.email)
    if user&.authenticate(context.password)
      if user.email_verified
        context.user = user
      else
        context.fail!(message: "Please verify your email before logging in.")
      end
    else
      context.fail!(message: "Invalid credentials.")
    end
  end
end