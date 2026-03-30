class SessionsController < ApplicationController
  def index
    @sessions = current_user.sessions
                            .where("expires_at > ?", Time.current)
                            .order(created_at: :desc)
  end

  def destroy
    @session = current_user.sessions.find_by(id: params[:id])

    if @session
      if is_current?
        remove_tokens(current_user)
        redirect_to web_login_path, notice: "Logged out successfully"
      else
        @session.destroy
        redirect_to sessions_path, notice: "Successfully logged out #{@session.device_info} with id:#{@session.id}"
      end
    end
  end

  def remove_session(session_id)
    current_user.sessions.find(session_id).destroy
  end
  private
  
  def is_current?
    @session.session_token == get_session_id
  end

end
