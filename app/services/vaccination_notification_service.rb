class VaccinationNotificationService
  REMINDER_DAYS_BEFORE = 3   # 3日前にリマインダー
  ALERT_HOUR_START    = 8   # アラート開始時刻（当日朝8時）

  def self.create_notifications_for(child)
    child.vaccinations.find_each do |vaccination|
      begin
        # --- リマインダー ---
        if vaccination.vaccinated_at
          reminder_time = vaccination.vaccinated_at - REMINDER_DAYS_BEFORE.days
          if Time.current.to_i.between?(reminder_time.to_i, (reminder_time + 59.seconds).to_i)
            notification_exists = Notification.exists?(
              child: child,
              target: vaccination,
              target_type: "Vaccination",
              notification_kind: :reminder
            )
            unless notification_exists
              Notification.create!(
                user: vaccination.user,
                child: child,
                target: vaccination,
                target_type: "Vaccination",
                notification_kind: :reminder,
                title: "💉 予防接種",
                message: "リマインダー: 予防接種日まであと3日です (#{vaccination.vaccine_name})",
                delivered_at: Time.current
              )
            end
          end
        end

        # --- アラート ---
        if vaccination.vaccinated_at&.to_date == Date.current
          if Time.current.hour >= ALERT_HOUR_START
            notification_exists = Notification.where(
              child: child,
              target: vaccination,
              target_type: "Vaccination",
              notification_kind: :alert
            ).where("DATE(delivered_at) = ?", Date.current).exists?

            unless notification_exists
              Notification.create!(
                user: vaccination.user,
                child: child,
                target: vaccination,
                target_type: "Vaccination",
                notification_kind: :alert,
                title: "💉 予防接種",
                message: "アラート: 今日は予防接種予定日です (#{vaccination.vaccine_name})",
                delivered_at: Time.current
              )
            end
          end
        end
      rescue => e
        Rails.logger.error("VaccinationNotificationService error for child_id=#{child.id}, vaccination_id=#{vaccination.id}: #{e.message}")
        next
      end
    end
  end
end
