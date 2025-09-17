class DiaperNotificationService
  def self.create_notifications_for(child)
    latest_diaper = child.diapers.order(changed_at: :desc).first
    return unless latest_diaper

    hours_since_last_change = ((Time.current - latest_diaper.changed_at) / 1.hour).floor

    # Diaper に紐づくユーザー全員をループ
    child.users.each do |user|
      # 各ユーザーの diaper 通知設定を取得
      setting = user.notification_settings.find_by(target_type: "diaper")
      next unless setting

      # reminder チェック
      if setting.reminder_on? && setting.reminder_after.present? &&
         hours_since_last_change == setting.reminder_after
        create_notification(child, latest_diaper, user, :reminder, hours_since_last_change)
      end

      # alert チェック
      if setting.alert_on? && setting.alert_after.present? &&
         hours_since_last_change == setting.alert_after
        create_notification(child, latest_diaper, user, :alert, hours_since_last_change)
      end
    end
  end

  def self.create_notification(child, latest_diaper, user, kind, hours_since_last_change)
    # 重複チェック
    notification_exists = Notification.where(
      child: child,
      target_type: "Diaper",
      target_id: latest_diaper.id,
      user: user,
      notification_kind: kind
    ).where("message LIKE ?", "%#{hours_since_last_change}時間%").exists?

    return if notification_exists

    message = case kind
    when :reminder
                "リマインダー: 前回のオムツ交換から#{hours_since_last_change}時間経過しました"
    when :alert
                "アラート: 前回のオムツ交換から#{hours_since_last_change}時間以上経過しています"
    end

    Notification.create!(
      user: user,
      child: child,
      target: latest_diaper,
      notification_kind: kind,
      title: "💩 おむつ",
      message: message,
      delivered_at: Time.current
    )
  end
end
