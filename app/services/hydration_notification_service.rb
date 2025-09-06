# app/services/hydration_notification_service.rb
class HydrationNotificationService
  NOTIFICATION_HOURS = { reminder: [ 3, 4 ] }
  DAILY_ALERT_INTERVALS = [ 3, 6, 9, 12, 15, 18, 21 ]

  def self.create_notifications_for(child)
    latest_hydration = child.hydrations.order(fed_at: :desc).first

    # --- 時間経過リマインダー ---
    if latest_hydration
      hours_since_last_hydration = ((Time.current - latest_hydration.fed_at) / 1.hour).floor
      NOTIFICATION_HOURS.each do |kind, hours_array|
        next unless hours_array.include?(hours_since_last_hydration)

        notification_exists = Notification.where(
          child: child,
          target: latest_hydration,
          target_type: "Hydration",
          notification_kind: kind
        ).where("message LIKE ?", "%#{hours_since_last_hydration}時間%").exists?
        next if notification_exists

        Notification.create!(
          user: latest_hydration.user,
          child: child,
          target: latest_hydration,
          notification_kind: kind,
          title: "💧 水分補給",
          message: "リマインダー: 前回の水分補給から#{hours_since_last_hydration}時間経過しました",
          delivered_at: Time.current
        )
      end
    end

    # --- 1日の摂取量チェック（不足アラート） ---
    today_hydrations = child.hydrations.where("DATE(fed_at) = ?", Date.current)
    past_hydrations  = child.hydrations.where.not(amount: nil)
    return if past_hydrations.empty?

    today_total = today_hydrations.sum(:amount) || 0
    today_count = today_hydrations.count { |h| h.amount.present? }
    daily_goal  = child.daily_hydration_goal || 200
    return if today_total >= daily_goal

    hours_since_midnight = ((Time.current - Time.current.beginning_of_day) / 1.hour).floor
    DAILY_ALERT_INTERVALS.each do |interval|
      next unless hours_since_midnight >= interval && hours_since_midnight < interval + 3

      notification_exists = Notification.where(
        child: child,
        target_type: "Hydration",
        notification_kind: :alert
      ).where("message LIKE ?", "%#{today_total}ml%").exists?
      next if notification_exists

      target = latest_hydration
      Notification.create!(
        user: target&.user || child.user,
        child: child,
        target: target,
        notification_kind: :alert,
        title: "💧 水分補給不足アラート",
        message: "アラート: 今日の水分摂取量が不足しています（現在 #{today_total}ml / #{today_count}回 / 目標 #{daily_goal}ml）",
        delivered_at: Time.current
      )
    end
  end
end
