class NotificationJob < ApplicationJob
  queue_as :default

  def perform
    Child.find_each do |child|
      FeedNotificationService.create_notifications_for(child)
    end
  end
end
