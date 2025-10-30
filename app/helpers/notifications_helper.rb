module NotificationsHelper
  # カード全体用: モデルの index ページへ
  def notification_target_path(notification)
    return "#" unless notification.target_type.present?

    case notification.target_type
    when "Feed"
      child_feeds_path(notification.child_id)
    when "Diaper"
      child_diapers_path(notification.child_id)
    when "Bottle"
      child_bottles_path(notification.child_id)
    when "Hydration"
      child_hydrations_path(notification.child_id)
    when "BabyFood"
      child_baby_foods_path(notification.child_id)
    when "SleepRecord"
      child_sleep_records_path(notification.child_id)
    when "Bath"
      child_baths_path(notification.child_id)
    when "Temperature"
      child_temperatures_path(notification.child_id)
    when "Vaccination"
      child_vaccinations_path(notification.child_id)
    when "Schedule"
      schedules_path
    else
      "#" # デフォルト
    end
  end
end
