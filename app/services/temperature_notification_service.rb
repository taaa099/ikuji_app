class TemperatureNotificationService
  FEVER_THRESHOLD = 37.5 # 37.6℃ 以上で通知

  def self.create_notifications_for(child)
    latest_temp = child.temperatures.order(measured_at: :desc).first
    return if latest_temp.nil? || latest_temp.temperature.nil?

    # 発熱アラート（37.6℃ 以上）
    if latest_temp.temperature > FEVER_THRESHOLD
      notification_exists = Notification.exists?(
        child: child,
        target: latest_temp,
        target_type: "Temperature",
        notification_kind: :alert
      )
      return if notification_exists

      Notification.create!(
        user: latest_temp.user || child.user,
        child: child,
        target: latest_temp,
        target_type: "Temperature",
        notification_kind: :alert,
        title: "🌡️ 体温",
        message: "アラート: 発熱注意（#{latest_temp.temperature}℃）",
        delivered_at: Time.current
      )
    end
  rescue => e
    Rails.logger.error("TemperatureNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end