class FeedNotificationService
  def self.create_notifications_for(child)
    latest_feed = child.feeds.order(fed_at: :desc).first
    return unless latest_feed

    hours_since_last_feed = ((Time.current - latest_feed.fed_at) / 1.hour).floor

    # Feed に紐づくユーザー全員をループ
    child.users.each do |user|
      # 各ユーザーの feed 通知設定を取得
      setting = user.notification_settings.find_by(target_type: "feed")
      next unless setting

      # reminder チェック
      if setting.reminder_on? && setting.reminder_after.present? &&
         hours_since_last_feed == setting.reminder_after
        create_notification(child, latest_feed, user, :reminder, hours_since_last_feed)
      end

      # alert チェック
      if setting.alert_on? && setting.alert_after.present? &&
         hours_since_last_feed == setting.alert_after
        create_notification(child, latest_feed, user, :alert, hours_since_last_feed)
      end
    end
  end

  def self.create_notification(child, latest_feed, user, kind, hours_since_last_feed)
    # 重複チェック
    notification_exists = Notification.where(
      child: child,
      target_type: "Feed",
      target_id: latest_feed.id,
      user: user,
      notification_kind: kind
    ).where("message LIKE ?", "%#{hours_since_last_feed}時間%").exists?

    return if notification_exists

    message = case kind
    when :reminder
                "前回の授乳から#{hours_since_last_feed}時間経過しました"
    when :alert
                "授乳間隔が通常より長すぎます！（#{hours_since_last_feed}時間）"
    end

    Notification.create!(
      user: user,
      child: child,
      target: latest_feed,
      notification_kind: kind,
      title: "🍼 授乳",
      message: message,
      delivered_at: Time.current
    )
  end
end
