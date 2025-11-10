# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)
    if resource
      # ログイン成功は親に任せる
      super
    else
      # ログイン失敗
      flash.now[:alert] = "メールアドレスまたはパスワードが違います。"
      self.resource = resource_class.new(sign_in_params)

      respond_to do |format|
        # 同期 HTML の場合
        format.html { render :new, status: :unprocessable_entity }

        # Turbo Stream の場合
        format.turbo_stream do
          render turbo_stream: turbo_stream.update(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: flash }
          )
        end
      end
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
