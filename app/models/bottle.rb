class Bottle < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :validate_amount
  validates :given_at, presence: true

  private

  def validate_amount
    if amount.blank?
     errors.add(:amount, "を入力してください")
    elsif !amount.is_a?(Numeric)
     errors.add(:amount, "は数値で入力してください")
    elsif amount < 1
     errors.add(:amount, "は1以上で入力してください")
    end
  end

  def create_default_notification
    last_bottle = child.bottles.where.not(id: id).order(given_at: :desc).first
    return unless last_bottle

    hours_since_last_bottle = ((self.given_at - last_bottle.given_at) / 1.hour).round(1)

    if hours_since_last_bottle >= 3 && hours_since_last_bottle < 5
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "🍼 ミルク",
        message: "リマインダー: 前回のミルクから#{hours_since_last_bottle}時間経過しました",
        delivered_at: Time.current
      )
    end

    # 今日の摂取量チェック（アラート）
    if child.bottles.where('DATE(given_at) = ?', Date.current).sum(:amount) < child.daily_bottle_goal
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🍼 ミルク",
        message: "アラート: 今日の摂取量が少ないです",
        delivered_at: Time.current
      )
    end
  end
end
