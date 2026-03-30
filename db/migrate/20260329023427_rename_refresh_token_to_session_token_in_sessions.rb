class RenameRefreshTokenToSessionTokenInSessions < ActiveRecord::Migration[8.1]
  def change
    rename_column :sessions, :refresh_token, :session_token
  end
end
