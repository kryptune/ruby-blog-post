class RegisterUser
  include Interactor

  def call 
    user = User.new(context.to_h)
    if user.save
      context.user = user
    else
      context.fail!(message: user.errors.full_messages.join(", "))
    end
  end
end
