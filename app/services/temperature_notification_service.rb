class TemperatureNotificationService
  DEFAULT_FEVER_THRESHOLD = 37.5 # デフォルト値

  def self.create_notifications_for(child)
    latest_temp = child.temperatures.order(measured_at: :desc).first
    if latest_temp.nil? || latest_temp.temperature.nil?
      Rails.logger.info("No valid temperature record for child_id=#{child.id}")
      return
    end

    # --- ユーザー設定を取得 ---
    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "temperature")
      threshold = setting&.alert_threshold || DEFAULT_FEVER_THRESHOLD
      Rails.logger.info("Checking temperature alert for user_id=#{user.id}, threshold=#{threshold}, latest_temp=#{latest_temp.temperature}")

      next unless setting&.alert_on? # ユーザーがアラートONの場合のみ

      if latest_temp.temperature > threshold
        notification_exists = Notification.exists?(
          child: child,
          target: latest_temp,
          target_type: "Temperature",
          user: user,
          notification_kind: :alert
        )
        if notification_exists
          Rails.logger.info("Temperature alert already exists for child_id=#{child.id}, user_id=#{user.id}")
          next
        end

        Notification.create!(
          user: user,
          child: child,
          target: latest_temp,
          target_type: "Temperature",
          notification_kind: :alert,
          title: "🌡️ 体温",
          message: "アラート: 発熱注意（#{latest_temp.temperature}℃）",
          delivered_at: Time.current
        )
        Rails.logger.info("Created temperature alert for child_id=#{child.id}, user_id=#{user.id}")
      else
        Rails.logger.info("Temperature below threshold for user_id=#{user.id}")
      end
    end
  rescue => e
    Rails.logger.error("TemperatureNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
