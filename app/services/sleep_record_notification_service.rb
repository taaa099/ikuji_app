class SleepRecordNotificationService
  SHORT_SLEEP_MINUTES = 30   # 短すぎる睡眠の閾値（分）
  LONG_SLEEP_HOURS    = 4    # 長すぎる睡眠の閾値（時間）

  def self.create_notifications_for(child)
    Rails.logger.info("SleepRecordNotificationService start for child_id=#{child.id}")

    latest_sleep = child.sleep_records.order(end_time: :desc, start_time: :desc).first
    if latest_sleep.nil? || latest_sleep.start_time.nil?
      Rails.logger.info("No valid latest sleep for child_id=#{child.id}")
      return
    end
    Rails.logger.info("Latest sleep: #{latest_sleep.inspect}")

    reference_time = latest_sleep.end_time || latest_sleep.start_time
    if reference_time > Time.current
      Rails.logger.info("Reference time is in the future: #{reference_time}")
      return
    end

    # --- リマインダー（ユーザー設定）---
    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "sleep_record")
      Rails.logger.info("Checking reminder for user_id=#{user.id}, setting=#{setting&.attributes}")

      next unless setting&.reminder_on? && setting.reminder_after.present?

      if reference_time.hour.between?(9, 16)
        hours_since_last_sleep = ((Time.current - reference_time) / 1.hour).floor
        Rails.logger.info("User=#{user.id}, hours_since_last_sleep=#{hours_since_last_sleep}, reminder_after=#{setting.reminder_after}")

        if hours_since_last_sleep == setting.reminder_after
          notification_exists = Notification.exists?(
            child: child,
            target: latest_sleep,
            target_type: "SleepRecord",
            user: user,
            notification_kind: :reminder
          )

          if notification_exists
            Rails.logger.info("Reminder already exists for child_id=#{child.id}, user_id=#{user.id}")
            next
          end

          Notification.create!(
            user: user,
            child: child,
            target: latest_sleep,
            target_type: "SleepRecord",
            notification_kind: :reminder,
            title: "🛌 睡眠",
            message: "昼寝の前回の睡眠から#{hours_since_last_sleep}時間起きています",
            delivered_at: Time.current
          )
          Rails.logger.info("Created reminder notification for child_id=#{child.id}, user_id=#{user.id}")
        else
          Rails.logger.info("Reminder condition not met (needed #{setting.reminder_after}h, got #{hours_since_last_sleep}h)")
        end
      else
        Rails.logger.info("Reference time not in daytime (9-16), hour=#{reference_time.hour}")
      end
    end

    # --- アラート（固定仕様: 昼寝の長さチェック）---
    today_sleeps = child.sleep_records.where("DATE(start_time) = ?", Date.current)
                                     .where.not(start_time: nil, end_time: nil)
    Rails.logger.info("Found #{today_sleeps.count} sleep records for today child_id=#{child.id}")

    today_sleeps.each do |sleep|
      Rails.logger.info("Checking sleep id=#{sleep.id}, start=#{sleep.start_time}, end=#{sleep.end_time}")

      if sleep.end_time.nil? || sleep.end_time > Time.current
        Rails.logger.info("Skip sleep id=#{sleep.id}: end_time invalid or in future")
        next
      end

      is_daytime = sleep.start_time.hour.between?(9, 16)
      Rails.logger.info("Sleep id=#{sleep.id} daytime?=#{is_daytime}")
      next unless is_daytime

      duration_minutes = ((sleep.end_time - sleep.start_time) / 60).to_i
      duration_str = duration_minutes >= 60 ? "#{(duration_minutes / 60.0).round(1)}時間" : "#{duration_minutes}分"
      start_str = sleep.start_time.strftime("%H:%M")
      end_str   = sleep.end_time.strftime("%H:%M")

      if duration_minutes < SHORT_SLEEP_MINUTES
        alert_message = "本日の昼寝（#{start_str}〜#{end_str}）は#{duration_str}で、やや短めです"
      elsif duration_minutes >= LONG_SLEEP_HOURS * 60
        alert_message = "本日の昼寝（#{start_str}〜#{end_str}）は#{duration_str}で、やや長めです"
      else
        Rails.logger.info("Sleep id=#{sleep.id} duration normal (#{duration_minutes}分)")
        next
      end

      notification_exists = Notification.exists?(
        child: child,
        target: sleep,
        target_type: "SleepRecord",
        notification_kind: :alert
      )
      if notification_exists
        Rails.logger.info("Alert already exists for sleep id=#{sleep.id}")
        next
      end

      Notification.create!(
        user: sleep.user || child.user,
        child: child,
        target: sleep,
        target_type: "SleepRecord",
        notification_kind: :alert,
        title: "🛌 睡眠",
        message: alert_message,
        delivered_at: Time.current
      )
      Rails.logger.info("Created alert notification for child_id=#{child.id}, sleep_id=#{sleep.id}")
    end
  rescue => e
    Rails.logger.error("SleepRecordNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
