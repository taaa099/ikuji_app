class VaccinationNotificationService
  REMINDER_HOUR = 19..23 # リマインダーは19時〜23時の間のみ

  def self.create_notifications_for(child)
    Rails.logger.info("VaccinationNotificationService start for child_id=#{child.id}")

    now = Time.current

    child.users.each do |user|
      setting = user.notification_settings.find_by(target_type: "vaccination")
      next unless setting

      # --- リマインダー ---
      if setting.reminder_on? && setting.reminder_after.present? && REMINDER_HOUR.cover?(now.hour)
        target_date = Date.current + setting.reminder_after.days
        vaccinations = child.vaccinations.where("DATE(vaccinated_at) = ?", target_date)

        if vaccinations.any?
          notification_exists = Notification.where(
            child: child,
            target_type: "Vaccination",
            notification_kind: :reminder,
            user: user
          ).where("DATE(delivered_at) = ?", Date.current)
           .exists?

          unless notification_exists
            names = vaccinations.map(&:vaccine_name).join(" / ")
            Notification.create!(
              user: user,
              child: child,
              target: vaccinations.first,
              target_type: "Vaccination",
              notification_kind: :reminder,
              title: "💉 予防接種",
              message: "リマインダー: #{target_date.strftime("%m/%d")}に予防接種予定があります（#{names}）",
              delivered_at: now
            )
            Rails.logger.info("Created vaccination reminder for child_id=#{child.id}, user_id=#{user.id}, vaccinations=#{vaccinations.pluck(:id).join(',')}")
          end
        end
      end

      # --- アラート ---
      if setting.alert_on?
        today = Date.current
        vaccinations = child.vaccinations.where("DATE(vaccinated_at) = ?", today)

        if vaccinations.any?
          if setting.alert_time.present?
            alert_hour = setting.alert_time.hour
            alert_min  = setting.alert_time.min
            # 指定された時間の「その分」だけ実行する
            next unless now.hour == alert_hour && now.min == alert_min
          end

          # 当日アラートがすでに同じ分に送られていないかチェック
          notification_exists = Notification.where(
            child: child,
            target_type: "Vaccination",
            notification_kind: :alert,
            user: user
          ).where("DATE(delivered_at) = ?", today)
           .where("EXTRACT(HOUR FROM delivered_at) = ? AND EXTRACT(MINUTE FROM delivered_at) = ?", now.hour, now.min)
           .exists?

          unless notification_exists
            names = vaccinations.map(&:vaccine_name).join(" / ")
            Notification.create!(
              user: user,
              child: child,
              target: vaccinations.first,
              target_type: "Vaccination",
              notification_kind: :alert,
              title: "💉 予防接種",
              message: "アラート: 本日は予防接種予定日です（#{names}）",
              delivered_at: now
            )
            Rails.logger.info("Created vaccination alert for child_id=#{child.id}, user_id=#{user.id}, vaccinations=#{vaccinations.pluck(:id).join(',')}")
          end
        end
      end
    end
  rescue => e
    Rails.logger.error("VaccinationNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
