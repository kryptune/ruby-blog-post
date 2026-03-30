class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :refresh_token
      t.string :device_info
      t.string :ip_address
      t.timestamptz :expires_at

      t.timestamps
    end
  end
end
