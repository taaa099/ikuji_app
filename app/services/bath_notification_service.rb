class BathNotificationService
  REMINDER_HOURS = [ 21, 22, 23 ] # リマインダー対象時間（21〜23時）

  def self.create_notifications_for(child)
    Rails.logger.info("BathNotificationService start for child_id=#{child.id}")

    latest_bath = child.baths.order(bathed_at: :desc).first
    Rails.logger.info("Latest bath: #{latest_bath.inspect}")

    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "bath")
      Rails.logger.info("User=#{user.id} setting=#{setting&.attributes}")

      next unless setting&.reminder_on? || setting&.alert_on?

      # --- リマインダー（21〜23時、記録なしの場合） ---
      if setting&.reminder_on? &&
         (latest_bath.nil? || latest_bath.bathed_at.to_date != Date.current) &&
         REMINDER_HOURS.include?(Time.current.hour)

        if latest_bath
          notification_exists = Notification.exists?(
            child: child,
            target: latest_bath,
            target_type: "Bath",
            notification_kind: :reminder,
            user: user
          )

          unless notification_exists
            Notification.create!(
              user: user,
              child: child,
              target: latest_bath,
              target_type: "Bath",
              notification_kind: :reminder,
              title: "🛁 お風呂",
              message: "本日の入浴記録がまだありません",
              delivered_at: Time.current
            )
            Rails.logger.info("Created reminder notification for user_id=#{user.id}")
          end
        else
          Rails.logger.info("Skipping reminder for child_id=#{child.id}, no latest bath record")
        end
      end

      # --- アラート（最後の入浴から alert_after 日経過） ---
      if setting&.alert_on? && latest_bath && setting.alert_after.present?
        days_since_last_bath = ((Time.current.to_date - latest_bath.bathed_at.to_date).to_i)
        Rails.logger.info("User=#{user.id} days_since_last_bath=#{days_since_last_bath}, alert_after=#{setting.alert_after}")

        if days_since_last_bath >= setting.alert_after
          notification_exists = Notification.exists?(
            child: child,
            target: latest_bath,
            target_type: "Bath",
            notification_kind: :alert,
            user: user
          )

          unless notification_exists
            Notification.create!(
              user: user,
              child: child,
              target: latest_bath,
              target_type: "Bath",
              notification_kind: :alert,
              title: "🛁 お風呂",
              message: "最後の入浴から#{days_since_last_bath}日以上経過しました",
              delivered_at: Time.current
            )
            Rails.logger.info("Created alert notification for user_id=#{user.id}")
          end
        end
      end
    end
  rescue => e
    Rails.logger.error("BathNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
