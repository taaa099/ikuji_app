class NotificationSetting < ApplicationRecord
  belongs_to :user

  # reminder_after は 1〜12 の整数
  validates :reminder_after, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 12 }, allow_nil: true

  # alert_after は 1〜6 の整数
  validates :alert_after, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 6 }, allow_nil: true

  # alert_threshold は体温専用で 35.0〜42.0
  validates :alert_threshold, numericality: { greater_than_or_equal_to: 35.0, less_than_or_equal_to: 42.0 }, allow_nil: true, if: -> { target_type == "temperature" }

  enum :target_type, {
    feed: "Feed",
    diaper: "Diaper",
    bottle: "Bottle",
    hydration: "Hydration",
    baby_food: "BabyFood",
    sleep_record: "SleepRecord",
    temperature: "Temperature",
    bath: "Bath",
    vaccination: "Vaccination",
    schedule: "Schedule"
  }
end
