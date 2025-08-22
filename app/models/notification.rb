class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :child
  belongs_to :target, polymorphic: true

  enum :notification_kind { reminder: 0, alert: 1 },  _suffix: true
end
