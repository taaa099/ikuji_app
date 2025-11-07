class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!

  def edit
    super
  end

  def account
    self.resource = current_user
    render "devise/registrations/account"
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    case params[:form_type]
    when "password"
      # パスワード変更フォーム
      if update_password(resource, account_update_params)
        bypass_sign_in resource, scope: resource_name
        redirect_to edit_user_registration_path, notice: "パスワードを変更しました。"
      else
        clean_up_passwords resource
        set_minimum_password_length
        render :edit, status: :unprocessable_entity
      end

    when "profile"
      # プロフィール更新フォーム
      if update_profile(resource, profile_update_params)
        redirect_to user_account_path, notice: "プロフィールを更新しました。"
      else
        render :account, status: :unprocessable_entity
      end

    else
      redirect_to root_path, alert: "不正なリクエストです。"
    end
  end

  protected

  # ===== パスワード更新 =====
  def update_password(resource, params)
    has_error = false

    if params[:current_password].blank?
      resource.errors.add(:current_password, "を入力してください")
      has_error = true
    elsif !resource.valid_password?(params[:current_password])
      resource.errors.add(:current_password, "が正しくありません")
      has_error = true
    end

    if params[:password].blank?
      resource.errors.add(:password, "を入力してください")
      has_error = true
    end

    if params[:password_confirmation].blank?
      resource.errors.add(:password_confirmation, "を入力してください")
      has_error = true
    end

    return false if has_error
    resource.update_with_password(params)
  end

  # ===== プロフィール更新 =====
  def update_profile(resource, params)
    has_error = false

    if params[:name].blank?
      resource.errors.add(:name, "を入力してください")
      resource.name = "" # nameだけ空欄に戻す
      has_error = true
    end

    if params[:email].blank?
      resource.errors.add(:email, "を入力してください")
      resource.email = "" # emailだけ空欄に戻す
      has_error = true
    end

    return false if has_error

    resource.update(params)
  end

  private

  def profile_update_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def account_update_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
