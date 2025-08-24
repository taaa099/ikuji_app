class Feed < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :left_or_right_time_present
  validates :fed_at, presence: true

  private

  def left_or_right_time_present
   if (left_time.nil? || left_time == 0) && (right_time.nil? || right_time == 0)
    errors.add(:base, "左右どちらかの授乳時間を1秒以上入力してください")
   end
  end

  def create_default_notification
    last_feed = child.feeds.order(created_at: :desc).second # 今回の直前の授乳
    return unless last_feed

    hours_since_last_feed = ((Time.current - last_feed.created_at) / 1.hour).round(1)

    if hours_since_last_feed >= 3 && hours_since_last_feed < 5
      # リマインダー通知
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "🍼 授乳（feed）",
        message: "リマインダー: 前回の授乳から#{hours_since_last_feed}時間経過しました",
        delivered_at: Time.current
      )
    elsif hours_since_last_feed >= 5
      # アラート通知
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🍼 授乳（feed）",
        message: "アラート: 授乳間隔が通常より長すぎます！（#{hours_since_last_feed}時間）",
        delivered_at: Time.current
      )
    end
  end
end
