module SessionManager
  extend ActiveSupport::Concern
  include RenderFlash

  def find_user_from_session
    User.find_by(id: session[:user_id])
  end

  def session_logged_in?
    session_token = get_session_id
    unless session_token && Session.active.find_by(session_token: session_token)
      remove_tokens(current_user)
      render_flash("Session ended. Please log in.", web_login_path)
    end
  end

  def save_session(user, refresh_token = nil)
    # For web-based sessions (no refresh_token provided)
    session[:user_id] = user.id if refresh_token.nil?

    # For API-based sessions (refresh_token provided)
    user.sessions.create!(
      session_token: refresh_token || get_session_id , # Rails' internal session ID
      device_info: request.user_agent,
      ip_address: request.remote_ip,
      expires_at: (params[:remember_me] == "1" ? 30 : 7).days.from_now
    )
  end

  
  def remove_tokens(user)
    session_token = get_session_id
    user&.sessions&.find_by(session_token: session_token)&.destroy
    reset_session   # clears the session cookie
  end

  def get_session_id
    request.session.id.to_s 
  end
end

#TODO