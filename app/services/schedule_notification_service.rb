class ScheduleNotificationService
  REMINDER_HOUR = 19..23 # リマインダーは19時〜23時の間のみ

  def self.create_notifications_for(child)
    now = Time.current
    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "schedule")
      next unless setting

      # === リマインダー: 事前通知 ===
      if setting.reminder_on? && setting.reminder_after.present? && REMINDER_HOUR.cover?(now.hour)
        target_date = Date.current + setting.reminder_after.days
        schedules = child.schedules.where("DATE(start_time) = ?", target_date)

        if schedules.any?
          notification_exists = Notification.where(
            child: child,
            target_type: "Schedule",
            notification_kind: :reminder,
            user: user
          ).where("DATE(delivered_at) = ?", Date.current)
           .exists?

          unless notification_exists
            titles = schedules.map(&:title).join(" / ")
            Notification.create!(
              user: user,
              child: child,
              target: schedules.first,
              target_type: "Schedule",
              notification_kind: :reminder,
              title: "📅 スケジュール",
              message: "#{target_date.strftime("%m/%d")}に予定があります（#{titles}）",
              delivered_at: now
            )
            Rails.logger.info("Created schedule reminder for child_id=#{child.id}, user_id=#{user.id}, schedules=#{schedules.pluck(:id).join(',')}")
          end
        end
      end

      # === アラート: 当日通知 ===
      if setting.alert_on?
        today = Date.current
        schedules = child.schedules.where("DATE(start_time) = ?", today)

        if schedules.any?
          if setting.alert_time.present?
            alert_hour = setting.alert_time.hour
            alert_min  = setting.alert_time.min
            # ピッタリの時間だけ実行する
            next unless now.hour == alert_hour && now.min == alert_min
          end

          # 当日のアラートが既に同じ分に送られていないかチェック
          notification_exists = Notification.where(
           child: child,
           target_type: "Schedule",
           notification_kind: :alert,
            user: user
          ).where("DATE(delivered_at) = ?", today)
           .where("EXTRACT(HOUR FROM delivered_at) = ? AND EXTRACT(MINUTE FROM delivered_at) = ?", now.hour, now.min)
          .exists?

          unless notification_exists
            titles = schedules.map(&:title).join(" / ")
            Notification.create!(
              user: user,
              child: child,
              target: schedules.first,
              target_type: "Schedule",
              notification_kind: :alert,
              title: "📅 スケジュール",
              message: "本日の予定があります（#{titles}）",
              delivered_at: now
            )
            Rails.logger.info("Created schedule alert for child_id=#{child.id}, user_id=#{user.id}, schedules=#{schedules.pluck(:id).join(',')}")
          end
        end
      end
    end
  rescue => e
    Rails.logger.error("ScheduleNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
