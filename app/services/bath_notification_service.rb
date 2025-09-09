# app/services/bath_notification_service.rb
class BathNotificationService
  REMINDER_HOURS = [21, 22, 23] # リマインダー対象時間（21〜23時）
  ALERT_DAYS = 2                # 2日以上入浴なしでアラート

  def self.create_notifications_for(child)
    latest_bath = child.baths.order(bathed_at: :desc).first
    user_for_notification = latest_bath ? latest_bath.user : child.user

    Rails.logger.info("BathNotificationService start for child_id=#{child.id}")
    Rails.logger.info("Latest bath: #{latest_bath.inspect}")

    # --- リマインダー（本日の記録がまだない場合、21〜23時のみ） ---
    if (latest_bath.nil? || latest_bath.bathed_at.to_date != Date.current) &&
       REMINDER_HOURS.include?(Time.current.hour)
      
      notification_exists = Notification.exists?(
        child: child,
        target: latest_bath,
        target_type: "Bath",
        notification_kind: :reminder
      )

      Rails.logger.info("Reminder condition met")
      Rails.logger.info("Reminder notification exists? #{notification_exists}")

      unless notification_exists
        Rails.logger.info("Creating reminder notification")
        Notification.create!(
          user: user_for_notification,
          child: child,
          target: latest_bath,
          target_type: "Bath",
          notification_kind: :reminder,
          title: "🛁 お風呂",
          message: "リマインダー: 本日の入浴記録がまだありません",
          delivered_at: Time.current
        )
      end
    end

    # --- アラート（最後の入浴から2日以上経過） ---
    if latest_bath
      days_since_last_bath = (Date.current - latest_bath.bathed_at.to_date).to_i
      if days_since_last_bath >= ALERT_DAYS
        notification_exists = Notification.exists?(
          child: child,
          target: latest_bath,
          target_type: "Bath",
          notification_kind: :alert
        )

        Rails.logger.info("Alert condition met")
        Rails.logger.info("Alert notification exists? #{notification_exists}")

        unless notification_exists
          Rails.logger.info("Creating alert notification")
          Notification.create!(
            user: user_for_notification,
            child: child,
            target: latest_bath,
            target_type: "Bath",
            notification_kind: :alert,
            title: "🛁 お風呂",
            message: "アラート: 2日以上入浴記録がありません",
            delivered_at: Time.current
          )
        end
      end
    end
  rescue => e
    Rails.logger.error("BathNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end