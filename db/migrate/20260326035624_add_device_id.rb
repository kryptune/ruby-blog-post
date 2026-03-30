class AddDeviceId < ActiveRecord::Migration[8.1]
  def change
    add_column :sessions, :device_id, :string
    add_index :sessions, :device_id, unique: true
    add_index :sessions, :refresh_token, unique: true
  end
end
