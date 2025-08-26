class Temperature < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :measured_at, presence: true
  validates :temperature, presence: true,
  numericality: { greater_than_or_equal_to: 35.0, less_than_or_equal_to: 42.0, allow_nil: true }

  private

  # アラート通知
  def create_default_notification
    return unless temperature

    if temperature >= 37.5
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🌡️ 体温",
        message: "アラート: 発熱注意（#{temperature}℃）",
        delivered_at: Time.current
      )
    elsif temperature < 35.0
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🌡️ 体温",
        message: "アラート: 低体温傾向 → 体調確認（#{temperature}℃）",
        delivered_at: Time.current
      )
    end
  end
end
