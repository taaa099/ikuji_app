class AddDefaultToNotificationKindInNotifications < ActiveRecord::Migration[8.0]
  def change
    change_column_default :notifications, :notification_kind, 0
  end
end
