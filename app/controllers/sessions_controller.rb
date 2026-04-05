class SessionsController < ApplicationController
  def index
    @sessions = current_user.sessions
                            .where("expires_at > ?", Time.current)
                            .order(created_at: :desc)
  end

  def destroy
    @session = current_user.sessions.find_by(id: params[:id])

    if @session
        @session.destroy
        redirect_to sessions_path, notice: "Successfully logged out #{@session.device_info} with id:#{@session.id}"
    end
  end

end
