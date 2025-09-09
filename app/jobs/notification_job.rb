class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    Child.find_each do |child|
      FeedNotificationService.create_notifications_for(child)
      DiaperNotificationService.create_notifications_for(child)
      BottleNotificationService.create_notifications_for(child)
      HydrationNotificationService.create_notifications_for(child)
      BabyFoodNotificationService.create_notifications_for(child)
      SleepRecordNotificationService.create_notifications_for(child)
      TemperatureNotificationService.create_notifications_for(child)
      BathNotificationService.create_notifications_for(child)
      VaccinationNotificationService.create_notifications_for(child)
    end
  end
end
