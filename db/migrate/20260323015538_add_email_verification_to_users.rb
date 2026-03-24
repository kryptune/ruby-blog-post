class AddEmailVerificationToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_verified, :boolean
    add_column :users, :verification_token, :string
  end
end
