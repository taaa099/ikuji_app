class RenameNotificationTypeToNotificationKindInNotifications < ActiveRecord::Migration[8.0]
  def change
    rename_column :notifications, :notification_type, :notification_kind
  end
end
