class NotificationSettingsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!
  before_action :set_notification_setting, only: [ :update ]
  before_action :ensure_child_selected

  # PATCH /notification_settings/:id
  def update
    setting = current_user.notification_settings.find(params[:id])

    if setting.update(notification_setting_params)
      respond_to do |format|
        format.json { render json: { success: true, setting: setting } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: setting.errors.full_messages } }
      end
    end
  end

  private

  # target_type ごとの NotificationSetting を取得
  def set_notification_setting
    @notification_setting = current_user.notification_settings.find(params[:id])
  end

  # 更新可能なカラム
  def notification_setting_params
    params.require(:notification_setting).permit(
      :reminder_after,
      :alert_after,
      :alert_threshold,
      :reminder_on,
      :alert_on,
      :alert_time,
      :extra_settings
    )
  end
end
