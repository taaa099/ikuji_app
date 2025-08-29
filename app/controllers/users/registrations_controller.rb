class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!

  private

  def account_update_params
    params.require(:user).permit(
      :email, :name, :bio, :avatar, 
      :password, :password_confirmation, :current_password
    )
  end
end