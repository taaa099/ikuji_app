class BottleNotificationService
  INTERVAL_HOURS = 3 # 3時間固定

  def self.create_notifications_for(child)
    Rails.logger.info("BottleNotificationService start for child_id=#{child.id}")

    latest_bottle = child.bottles.order(given_at: :desc).first
    unless latest_bottle
      Rails.logger.info("No bottle records for child_id=#{child.id}")
      return
    end
    Rails.logger.info("Latest bottle: #{latest_bottle.inspect}")

    hours_since_last_bottle = ((Time.current - latest_bottle.given_at) / 1.hour).floor
    Rails.logger.info("Hours since last bottle: #{hours_since_last_bottle}")

    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "bottle")
      next unless setting
      Rails.logger.info("User=#{user.id} setting=#{setting.inspect}")

      # --- 時間経過リマインダー ---
      if setting.reminder_on? && setting.reminder_after.present? &&
         hours_since_last_bottle == setting.reminder_after
        create_time_based_notification(child, latest_bottle, user, hours_since_last_bottle)
      end

      # --- 1日の摂取量不足アラート（3時間固定インターバル） ---
      if setting.alert_on?
        today_bottles = child.bottles.where("DATE(given_at) = ?", Date.current)
        today_total    = today_bottles.sum(:amount)
        today_count    = today_bottles.count
        daily_goal     = child.daily_bottle_goal || 600
        today_total = 0 if today_bottles.empty? && child.bottles.exists?
        Rails.logger.info("Today total=#{today_total}, count=#{today_count}, goal=#{daily_goal}")

        next if today_total >= daily_goal

        # --- 3時間固定インターバル判定 ---
        now = Time.current
        interval_index = now.hour / INTERVAL_HOURS
        interval_start = now.change(hour: interval_index * INTERVAL_HOURS, min: 0, sec: 0)
        interval_end   = interval_start + INTERVAL_HOURS.hours
        Rails.logger.info("Checking fixed 3h interval for child_id=#{child.id}, user_id=#{user.id}, interval=#{interval_start}-#{interval_end}")

        notification_exists = Notification.where(
          child: child,
          target_type: "Bottle",
          user: user,
          notification_kind: :alert
        ).where("delivered_at >= ? AND delivered_at < ?", interval_start, interval_end).exists?

        unless notification_exists
          create_daily_goal_alert(child, latest_bottle, user, today_total, today_count, daily_goal)
        end
      end
    end
  end

  private

  def self.create_time_based_notification(child, latest_bottle, user, hours_since_last_bottle)
    notification_exists = Notification.where(
      child: child,
      target_type: "Bottle",
      target_id: latest_bottle.id,
      user: user,
      notification_kind: :reminder
    ).where("message LIKE ?", "%#{hours_since_last_bottle}時間%").exists?

    return if notification_exists

    Notification.create!(
      user: user,
      child: child,
      target: latest_bottle,
      notification_kind: :reminder,
      title: "🍼 ミルク",
      message: "前回のミルクから#{hours_since_last_bottle}時間経過しました",
      delivered_at: Time.current
    )
    Rails.logger.info("Created reminder notification for child_id=#{child.id}, user_id=#{user.id}")
  end

  def self.create_daily_goal_alert(child, latest_bottle, user, today_total, today_count, daily_goal)
    notification_exists = Notification.where(
      child: child,
      target_type: "Bottle",
      user: user,
      notification_kind: :alert
    ).where("message LIKE ?", "%#{today_total}ml%").exists?

    return if notification_exists

    Notification.create!(
      user: user,
      child: child,
      target: latest_bottle,
      notification_kind: :alert,
      title: "🍼 ミルク",
      message: "今日のミルク摂取量が不足しています\n現在 #{today_total}ml / #{today_count}回 / 目標 #{daily_goal}ml",
      delivered_at: Time.current
    )
    Rails.logger.info("Created alert notification for child_id=#{child.id}, user_id=#{user.id}, latest_bottle_id=#{latest_bottle.id}")
  end
end
