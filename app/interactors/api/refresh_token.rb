class RefreshToken
  include Interactor, ApiTokenManager

  def call 
    token = get_header_token
    session = Session.active.find_by(session_token: token)
    if session
      context.user = session.user
      session.touch(:updated_at)
      context.new_access_token = encode_token({ user_id: context.user.id, exp: 10.minutes.from_now.to_i })  
    else
      context.fail!(message: "Session expired or invalid")
    end
  end
end
