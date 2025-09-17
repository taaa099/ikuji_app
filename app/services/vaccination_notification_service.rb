class VaccinationNotificationService
  def self.create_notifications_for(child)
    Rails.logger.info("VaccinationNotificationService start for child_id=#{child.id}")

    child.vaccinations.find_each do |vaccination|
      begin
        # child.users を使って、複数ユーザーに通知
        child.users.each do |user|
          setting = user.notification_settings.find_by(target_type: "vaccination")
          next unless setting

          # --- リマインダー ---
          if setting.reminder_on? && setting.reminder_after.present? && vaccination.vaccinated_at.present?
            reminder_days = setting.reminder_after.to_i
            reminder_time = vaccination.vaccinated_at - reminder_days.days

            # 1時間幅で判定（安全）
            reminder_start = reminder_time.beginning_of_hour
            reminder_end   = reminder_time.end_of_hour

            if Time.current.between?(reminder_start, reminder_end)
              unless Notification.exists?(
                child: child,
                target: vaccination,
                target_type: "Vaccination",
                notification_kind: :reminder,
                user: user
              )
                Notification.create!(
                  user: user,
                  child: child,
                  target: vaccination,
                  target_type: "Vaccination",
                  notification_kind: :reminder,
                  title: "💉 予防接種",
                  message: "リマインダー: 予防接種日まであと#{reminder_days}日です (#{vaccination.vaccine_name})",
                  delivered_at: Time.current
                )
                Rails.logger.info("Created vaccination reminder for child_id=#{child.id}, user_id=#{user.id}")
              end
            end
          end

          # --- アラート ---
          if setting.alert_on? && setting.alert_time.present? && vaccination.vaccinated_at&.to_date == Date.current
            alert_time_today = vaccination.vaccinated_at.change(
              hour: setting.alert_time.hour,
              min: setting.alert_time.min,
              sec: 0
            )

            # アラートも1時間幅で判定
            alert_start = alert_time_today.beginning_of_hour
            alert_end   = alert_time_today.end_of_hour

            if Time.current.between?(alert_start, alert_end)
              unless Notification.exists?(
                child: child,
                target: vaccination,
                target_type: "Vaccination",
                notification_kind: :alert,
                user: user
              )
                Notification.create!(
                  user: user,
                  child: child,
                  target: vaccination,
                  target_type: "Vaccination",
                  notification_kind: :alert,
                  title: "💉 予防接種",
                  message: "アラート: 今日は予防接種予定日です (#{vaccination.vaccine_name})",
                  delivered_at: Time.current
                )
                Rails.logger.info("Created vaccination alert for child_id=#{child.id}, user_id=#{user.id}")
              end
            end
          end
        end
      rescue => e
        Rails.logger.error("VaccinationNotificationService error for child_id=#{child.id}, vaccination_id=#{vaccination.id}: #{e.message}")
      end
    end
  end
end
