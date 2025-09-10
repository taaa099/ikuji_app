module NotificationsHelper
  def notification_target_link(notification)
    return unless notification.target.present?

    case notification.target
    when Schedule
      link_to "Schedule 詳細へ", schedule_path(notification.target)
    when Vaccination
      link_to "Vaccination 詳細へ", child_vaccination_path(notification.target.child, notification.target)
    when Bottle
      link_to "Bottle 詳細へ", child_bottle_path(notification.target.child, notification.target)
    when Diaper
      link_to "Diaper 詳細へ", child_diaper_path(notification.target.child, notification.target)
    when Feed
      link_to "Feed 詳細へ", child_feed_path(notification.target.child, notification.target)
    when Hydration
      link_to "Hydration 詳細へ", child_hydration_path(notification.target.child, notification.target)
    when BabyFood
      link_to "BabyFood 詳細へ", child_baby_food_path(notification.target.child, notification.target)
    when SleepRecord
      link_to "SleepRecord 詳細へ", child_sleep_record_path(notification.target.child, notification.target)
    when Temperature
      link_to "Temperature 詳細へ", child_temperature_path(notification.target.child, notification.target)
    when Bath
      link_to "Bath 詳細へ", child_bath_path(notification.target.child, notification.target)
    when Growth
      link_to "Growth 詳細へ", child_growth_path(notification.target.child, notification.target)
    else
      link_to "#{notification.target_type} 詳細へ", polymorphic_path([ notification.target.child, notification.target ])
    end
  end
end
