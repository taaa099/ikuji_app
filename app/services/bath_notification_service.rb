class BathNotificationService
  REMINDER_HOURS = [ 21, 22, 23 ] # リマインダー対象時間（21〜23時）
  ALERT_DAYS = 2                 # 2日以上入浴なしでアラート

  def self.create_notifications_for(child)
    latest_bath = child.baths.order(bathed_at: :desc).first

    Rails.logger.info("BathNotificationService start for child_id=#{child.id}")
    Rails.logger.info("Latest bath: #{latest_bath.inspect}")

    # --- リマインダー（本日の記録がまだない場合、21〜23時のみ） ---
    if Bath.where(child: child).exists? &&
       (latest_bath.nil? || latest_bath.bathed_at.to_date != Date.current) &&
       REMINDER_HOURS.include?(Time.current.hour)

      users_for_notification = latest_bath ? [ latest_bath.user ] : child.users.to_a

      users_for_notification.each do |user|
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
            message: "リマインダー: 本日の入浴記録がまだありません",
            delivered_at: Time.current
          )
          Rails.logger.info("Created reminder notification for user_id=#{user.id}")
        end
      end
    end

    # --- アラート（最後の入浴から2日以上経過） ---
    if latest_bath
      days_since_last_bath = (Date.current - latest_bath.bathed_at.to_date).to_i
      if days_since_last_bath >= ALERT_DAYS
        users_for_notification = [ latest_bath.user ] # アラートは最新Bathのuserのみ通知

        users_for_notification.each do |user|
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
              message: "アラート: 2日以上入浴記録がありません",
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
