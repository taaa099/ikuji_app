class BottleNotificationService
  NOTIFICATION_HOURS = {
    reminder: [ 3, 4 ] # 3時間と4時間でリマインダー
  }

  DAILY_ALERT_INTERVALS = [ 3, 6, 9, 12, 15, 18, 21 ] # 3時間ごとのチェック

  def self.create_notifications_for(child)
    latest_bottle = child.bottles.order(given_at: :desc).first
    return unless latest_bottle

    # --- 時間経過リマインダー ---
    hours_since_last_bottle = ((Time.current - latest_bottle.given_at) / 1.hour).floor

    NOTIFICATION_HOURS.each do |kind, hours_array|
      next unless hours_array.include?(hours_since_last_bottle)

      notification_exists = Notification.where(
        child: child,
        target: latest_bottle,
        notification_kind: kind
      ).where("message LIKE ?", "%#{hours_since_last_bottle}時間%").exists?

      next if notification_exists

      message = "リマインダー: 前回のミルクから#{hours_since_last_bottle}時間経過しました"

      Notification.create!(
        user: latest_bottle.user,
        child: child,
        target: latest_bottle,
        notification_kind: kind,
        title: "🍼 ミルク",
        message: message,
        delivered_at: Time.current
      )
    end

    # --- 1日の摂取量チェック（不足アラート） ---
    today_bottles = child.bottles.where("DATE(given_at) = ?", Date.current)
    today_total   = today_bottles.sum(:amount)
    today_count   = today_bottles.count
    daily_goal    = child.daily_bottle_goal || 600
    return if today_total >= daily_goal

    hours_since_midnight = ((Time.current - Time.current.beginning_of_day) / 1.hour).floor

    DAILY_ALERT_INTERVALS.each do |interval|
      # 「interval時間以上、次のinterval未満」であればその時間帯
      next unless hours_since_midnight >= interval && hours_since_midnight < interval + 3

      # 同じ interval 帯で既に通知があるかチェック
      notification_exists = Notification.where(
        child: child,
        notification_kind: :alert
      ).where("message LIKE ?", "%#{today_total}ml%").exists?

      next if notification_exists

      message = "アラート: 今日のミルク摂取量が不足しています（現在 #{today_total}ml / #{today_count}回 / 目標 #{daily_goal}ml）"

      Notification.create!(
        user: latest_bottle.user,
        child: child,
        target: latest_bottle,
        notification_kind: :alert,
        title: "🍼 ミルク不足アラート",
        message: message,
        delivered_at: Time.current
      )
    end
  end
end
