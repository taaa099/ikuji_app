class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!
  before_action :set_current_tab, only: [ :edit, :update ]

  # GET /resource/edit
  def edit
    super
  end

def account
  # Devise 用のリソースをセット
  self.resource = current_user
  # ビューで form_for に resource を渡せば OK
  # self.resource_name は不要
end

  private

  # タブ情報をセット
  def set_current_tab
    # パラメータがあればそれを優先、なければ既存値かデフォルト profile
    @current_tab = if params[:tab].present?
                     params[:tab]
    elsif defined?(@current_tab)
                     @current_tab
    else
                     "profile"
    end
  end

  # プロフィール変更とパスワード変更で挙動を分ける
  def update_resource(resource, params)
    tab = params.delete(:tab)

    if tab == "password"
      # パスワード変更タブ
      if params[:password].blank? || params[:password_confirmation].blank?
        resource.errors.add(:password, "を入力してください")
        return false
      end

      unless resource.valid_password?(params[:current_password])
        resource.errors.add(:current_password, "が正しくありません")
        return false
      end

      # 正常なら Devise 標準更新
      super
    else
      # プロフィール変更タブは current_password 不要
      params.delete("current_password")
      resource.update_without_password(params)
    end
  end

  def account_update_params
    params.require(:user).permit(
      :email, :name, :bio, :avatar,
      :password, :password_confirmation, :current_password,
      :tab
    )
  end
end
