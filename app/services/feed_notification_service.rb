class FeedNotificationService
  NOTIFICATION_HOURS = {
    reminder: [3, 4], # 3時間と4時間のリマインダー
    alert: [5]         # 5時間以上でアラート
  }

  def self.create_notifications_for(child)
    latest_feed = child.feeds.order(fed_at: :desc).first
    return unless latest_feed

    hours_since_last_feed = ((Time.current - latest_feed.fed_at) / 1.hour).floor

    NOTIFICATION_HOURS.each do |kind, hours_array|
      next unless hours_array.include?(hours_since_last_feed)

      # 同じ Feed, 同じ kind, 同じ時間の通知が既にあるかチェック（LIKE で部分一致）
      notification_exists = Notification.exists?(
        child: child,
        target: latest_feed,
        notification_kind: kind
      ) && Notification.where(
        child: child,
        target: latest_feed,
        notification_kind: kind
      ).where("message LIKE ?", "%#{hours_since_last_feed}時間%").exists?

      next if notification_exists

      message = case kind
                when :reminder
                  "リマインダー: 前回の授乳から#{hours_since_last_feed}時間経過しました"
                when :alert
                  "アラート: 授乳間隔が通常より長すぎます！（#{hours_since_last_feed}時間）"
                end

      Notification.create!(
        user: latest_feed.user,
        child: child,
        target: latest_feed,
        notification_kind: kind,
        title: "🍼 授乳（feed）",
        message: message,
        delivered_at: Time.current
      )
    end
  end
end