class LogoutUser
  include Interactor, SessionManager

  def call 
    user = context.user
    token = context.refresh_token
    web = context.web
    logout_all_devices = context.logout_all 

    if logout_all_devices
      if user.sessions.any?
        user.sessions.destroy_all
        context.message = "Logged out of all devices."
      else
        context.fail!(message: "No active sessions to log out.")
      end
      return
    end

    if web
      context.message = "Logged out successfully"
    else
      session = Session.find_by(session_token: token)&.destroy
      if session
        context.message = "Logged out of this device."
      else
        context.fail!(message: "Invalid Token.")
      end
    end
  end
end
