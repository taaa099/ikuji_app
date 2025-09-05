class DiaperNotificationService
  NOTIFICATION_HOURS = {
    reminder: [3, 4], # 3時間と4時間のリマインダー
    alert: [5, 6]     # 5時間と6時間のアラート
  }

  def self.create_notifications_for(child)
    latest_diaper = child.diapers.order(changed_at: :desc).first
    return unless latest_diaper

    hours_since_last_change = ((Time.current - latest_diaper.changed_at) / 1.hour).floor

    NOTIFICATION_HOURS.each do |kind, hours_array|
      next unless hours_array.include?(hours_since_last_change)

      # 同じ Diaper, 同じ kind, 同じ時間の通知が既にあるかチェック
      notification_exists = Notification.exists?(
        child: child,
        target: latest_diaper,
        notification_kind: kind
      ) && Notification.where(
        child: child,
        target: latest_diaper,
        notification_kind: kind
      ).where("message LIKE ?", "%#{hours_since_last_change}時間%").exists?

      next if notification_exists

      message = case kind
                when :reminder
                  "リマインダー: 前回のオムツ交換から#{hours_since_last_change}時間経過しました"
                when :alert
                  "アラート: 前回のオムツ交換から#{hours_since_last_change}時間以上経過しています"
                end

      Notification.create!(
        user: latest_diaper.user,
        child: child,
        target: latest_diaper,
        notification_kind: kind,
        title: "💩 おむつ",
        message: message,
        delivered_at: Time.current
      )
    end
  end
end