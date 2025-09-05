class NotificationJob < ApplicationJob
  queue_as :default

  # child_id が nil の場合は全 child を処理
  def perform(child_id = nil)
    if child_id
      child = Child.find_by(id: child_id)
      FeedNotificationService.create_notifications_for(child) if child
    else
      Child.find_each do |child|
        FeedNotificationService.create_notifications_for(child)
      end
    end
  end
end