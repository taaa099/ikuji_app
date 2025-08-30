class RemoveTwoFactorColumnsFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :encrypted_otp_secret, :string if column_exists?(:users, :encrypted_otp_secret)
    remove_column :users, :encrypted_otp_secret_iv, :string if column_exists?(:users, :encrypted_otp_secret_iv)
    remove_column :users, :encrypted_otp_secret_salt, :string if column_exists?(:users, :encrypted_otp_secret_salt)
    remove_column :users, :otp_required_for_login, :boolean if column_exists?(:users, :otp_required_for_login)
  end
end