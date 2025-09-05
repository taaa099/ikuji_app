class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :child
  belongs_to :target, polymorphic: true

  enum :notification_kind, reminder: 0, alert: 1

  scope :unread, -> { where(read: false) }

  after_create_commit :broadcast_notification

  private

  def broadcast_notification
    NotificationChannel.broadcast_to(
      self.child,
      title: self.title,
      message: self.message,
      notification_kind: self.notification_kind
    )
  end
end
