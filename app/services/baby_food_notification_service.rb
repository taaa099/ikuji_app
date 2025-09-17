class BabyFoodNotificationService
  REMINDER_INTERVALS = {
    morning:   (10..14),  # 10:00〜14:59
    afternoon: (15..19),  # 15:00〜19:59
    evening:   (20..23)   # 20:00〜23:59
  }

  def self.create_notifications_for(child)
    Rails.logger.info("BabyFoodNotificationService start for child_id=#{child.id}")

    latest_food = child.baby_foods.order(fed_at: :desc).first
    unless latest_food
      Rails.logger.info("No baby food records for child_id=#{child.id}")
      return
    end

    today_foods = child.baby_foods.where("DATE(fed_at) = ?", Date.current)
    today_count = today_foods.count
    daily_goal  = child.daily_baby_food_goal || 3
    current_hour = Time.current.hour

    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "baby_food")
      next unless setting
      Rails.logger.info("User=#{user.id} setting=#{setting.inspect}")

      # --- リマインダー通知 ---
      if setting.reminder_on?
        REMINDER_INTERVALS.each do |period, range|
          next unless range.include?(current_hour)

          notification_exists = Notification.where(
            child: child,
            target: latest_food,
            target_type: "BabyFood",
            user: user,
            notification_kind: :reminder
          ).where("message LIKE ?", "%現在 #{today_count}回%").exists?
          next if notification_exists

          Notification.create!(
            user: user,
            child: child,
            target: latest_food,
            notification_kind: :reminder,
            title: "👶 離乳食",
            message: "リマインダー: 今日の離乳食は現在 #{today_count}回（目標 #{daily_goal}回）です",
            delivered_at: Time.current
          )
          Rails.logger.info("Created reminder notification for child_id=#{child.id}, user_id=#{user.id}")
        end
      end

      # --- アラート通知（0時に1回だけ）---
      if setting.alert_on? && current_hour == 0 && today_count < daily_goal
        notification_exists = Notification.where(
          child: child,
          target_type: "BabyFood",
          user: user,
          notification_kind: :alert
        ).where("message LIKE ?", "%現在 #{today_count}回%").exists?
        next if notification_exists

        Notification.create!(
          user: user,
          child: child,
          target: latest_food,
          notification_kind: :alert,
          title: "👶 離乳食不足アラート",
          message: "アラート: 本日の離乳食回数が未達成です（現在 #{today_count}回 / 目標 #{daily_goal}回）",
          delivered_at: Time.current
        )
        Rails.logger.info("Created alert notification for child_id=#{child.id}, user_id=#{user.id}")
      end
    end
  end
end
