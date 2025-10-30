class HydrationNotificationService
  INTERVAL_HOURS = 4 # 4時間固定

  def self.create_notifications_for(child)
    Rails.logger.info("HydrationNotificationService start for child_id=#{child.id}")

    latest_hydration = child.hydrations.order(fed_at: :desc).first
    unless latest_hydration
      Rails.logger.info("No hydration records for child_id=#{child.id}")
      return
    end
    Rails.logger.info("Latest hydration: #{latest_hydration.inspect}")

    hours_since_last_hydration = ((Time.current - latest_hydration.fed_at) / 1.hour).floor
    Rails.logger.info("Hours since last hydration: #{hours_since_last_hydration}")

    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "hydration")
      next unless setting
      Rails.logger.info("User=#{user.id} setting=#{setting.inspect}")

      # --- 時間経過リマインダー ---
      if setting.reminder_on? && setting.reminder_after.present? &&
         hours_since_last_hydration == setting.reminder_after
        create_time_based_notification(child, latest_hydration, user, hours_since_last_hydration)
      end

      # --- 1日の摂取量不足アラート（4時間固定インターバル） ---
      if setting.alert_on?
        today_hydrations = child.hydrations.where("DATE(fed_at) = ?", Date.current)
        today_total      = today_hydrations.sum(:amount)
        today_count      = today_hydrations.count
        daily_goal       = child.daily_hydration_goal || 800
        today_total = 0 if today_hydrations.empty? && child.hydrations.exists?
        Rails.logger.info("Today total=#{today_total}, count=#{today_count}, goal=#{daily_goal}")

        next if today_total >= daily_goal

        # --- 4時間固定インターバル判定 ---
        now = Time.current
        interval_index = now.hour / INTERVAL_HOURS
        interval_start = now.change(hour: interval_index * INTERVAL_HOURS, min: 0, sec: 0)
        interval_end   = interval_start + INTERVAL_HOURS.hours
        Rails.logger.info("Checking fixed 4h interval for child_id=#{child.id}, user_id=#{user.id}, interval=#{interval_start}-#{interval_end}")

        notification_exists = Notification.where(
          child: child,
          target_type: "Hydration",
          user: user,
          notification_kind: :alert
        ).where("delivered_at >= ? AND delivered_at < ?", interval_start, interval_end).exists?

        if notification_exists
          Rails.logger.info("Alert already sent in this interval for child_id=#{child.id}, user_id=#{user.id}")
        else
          create_daily_goal_alert(child, latest_hydration, user, today_total, today_count, daily_goal)
        end
      end
    end
  end

  private

  # 時間経過リマインダー
  def self.create_time_based_notification(child, latest_hydration, user, hours_since_last_hydration)
    notification_exists = Notification.where(
      child: child,
      target_type: "Hydration",
      target_id: latest_hydration.id,
      user: user,
      notification_kind: :reminder
    ).where("message LIKE ?", "%#{hours_since_last_hydration}時間%").exists?

    return if notification_exists

    Notification.create!(
      user: user,
      child: child,
      target: latest_hydration,
      notification_kind: :reminder,
      title: "💧 水分補給",
      message: "前回の水分補給から#{hours_since_last_hydration}時間経過しました",
      delivered_at: Time.current
    )
    Rails.logger.info("Created reminder notification for child_id=#{child.id}, user_id=#{user.id}")
  end

  # 1日の摂取量不足アラート（4時間インターバル固定）
  def self.create_daily_goal_alert(child, latest_hydration, user, today_total, today_count, daily_goal)
    notification_exists = Notification.where(
      child: child,
      target_type: "Hydration",
      user: user,
      notification_kind: :alert
    ).where("message LIKE ?", "%#{today_total}ml%").exists?

    return if notification_exists

    Notification.create!(
      user: user,
      child: child,
      target: latest_hydration,
      notification_kind: :alert,
      title: "💧 水分補給",
      message: "今日の水分摂取量が不足しています（現在 #{today_total}ml / #{today_count}回 / 目標 #{daily_goal}ml）",
      delivered_at: Time.current
    )
    Rails.logger.info("Created alert notification for child_id=#{child.id}, user_id=#{user.id}, latest_hydration_id=#{latest_hydration.id}")
  end
end
