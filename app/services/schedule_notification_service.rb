class ScheduleNotificationService
  REMINDER_A_DAYS = 3   # デフォルト3日前
  REMINDER_A_HOUR = 19  # デフォルト19時
  REMINDER_B_HOUR = 8   # デフォルト当日8時

  def self.create_notifications_for(child)
    now = Time.current

    # === リマインダーA: 3日前の19時〜23:59にまとめて通知 ===
    if now.hour >= REMINDER_A_HOUR
      target_date = Date.current + REMINDER_A_DAYS
      schedules = child.schedules.where("DATE(start_time) = ?", target_date)

      if schedules.any?
        notification_exists = Notification.where(
          child: child,
          target_type: "Schedule",
          notification_kind: :reminder
        ).where("DATE(delivered_at) = ?", Date.current)
         .where("message LIKE ?", "%#{target_date}%")
         .exists?

        unless notification_exists
          titles = schedules.map(&:title).join(" / ")
          Notification.create!(
            user: schedules.first.user,
            child: child,
            target: schedules.first,
            target_type: "Schedule",
            notification_kind: :reminder,
            title: "📅 スケジュール",
            message: "リマインダー: #{target_date.strftime("%m/%d")}に予定があります（#{titles}）",
            delivered_at: now
          )
        end
      end
    end

    # === リマインダーB: 当日の8時以降に1回通知 ===
    if now.hour >= REMINDER_B_HOUR
      today = Date.current
      schedules = child.schedules.where("DATE(start_time) = ?", today)

      if schedules.any?
        notification_exists = Notification.where(
          child: child,
          target_type: "Schedule",
          notification_kind: :reminder
        ).where("DATE(delivered_at) = ?", today)
         .where("message LIKE ?", "%本日の予定%")
         .exists?

        unless notification_exists
          titles = schedules.map(&:title).join(" / ")
          Notification.create!(
            user: schedules.first.user,
            child: child,
            target: schedules.first,
            target_type: "Schedule",
            notification_kind: :reminder,
            title: "📅 スケジュール",
            message: "リマインダー: 本日の予定があります（#{titles}）",
            delivered_at: now
          )
        end
      end
    end

  rescue => e
    Rails.logger.error("ScheduleNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
