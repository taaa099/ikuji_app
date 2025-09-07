# app/services/baby_food_notification_service.rb
class BabyFoodNotificationService
  # リマインダー通知の時間帯（10時・15時・20時）
  REMINDER_INTERVALS = {
    morning:  (10..14),   # 10:00〜14:59
    afternoon:(15..19),   # 15:00〜19:59
    evening:  (20..23)    # 20:00〜23:59
  }

  def self.create_notifications_for(child)
    latest_food = child.baby_foods.order(fed_at: :desc).first
    return unless latest_food

    today_foods = child.baby_foods.where("DATE(fed_at) = ?", Date.current)
    today_count = today_foods.count
    daily_goal  = child.daily_baby_food_goal || 3

    # --- リマインダー通知 ---
    current_hour = Time.current.hour

    REMINDER_INTERVALS.each do |period, range|
      next unless range.include?(current_hour)

      notification_exists = Notification.where(
        child: child,
        target: latest_food,
        target_type: "BabyFood",
        notification_kind: :reminder
      ).where("message LIKE ?", "%現在 #{today_count}回%").exists?

      next if notification_exists

      Notification.create!(
        user: latest_food.user,
        child: child,
        target: latest_food,
        notification_kind: :reminder,
        title: "👶 離乳食",
        message: "リマインダー: 今日の離乳食は現在 #{today_count}回（目標 #{daily_goal}回）です",
        delivered_at: Time.current
      )
    end

    # --- アラート通知（0時に1回だけ）---
    if current_hour == 0
      return if today_count >= daily_goal

      notification_exists = Notification.where(
        child: child,
        target_type: "BabyFood",
        notification_kind: :alert
      ).where("message LIKE ?", "%現在 #{today_count}回%").exists?

      return if notification_exists

      Notification.create!(
        user: latest_food.user,
        child: child,
        target: latest_food,
        notification_kind: :alert,
        title: "👶 離乳食",
        message: "アラート: 本日の離乳食回数が未入力でした。現在 #{today_count}回 / 目標 #{daily_goal}回",
        delivered_at: Time.current
      )
    end
  end
end