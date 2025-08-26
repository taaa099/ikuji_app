class Hydration < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :fed_at, presence: true
  validates :drink_type, presence: true
  validates :amount, numericality: { greater_than: 0 }, allow_nil: true

  private

  def create_default_notification
    last_hydration = child.hydrations.where.not(id: id).order(fed_at: :desc).first
    return unless last_hydration

    hours_since_last_hydration = ((self.fed_at - last_hydration.fed_at) / 1.hour).round(1)

    # リマインダー通知
    if hours_since_last_hydration >= 2 && hours_since_last_hydration < 4
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "💧 水分補給",
        message: "リマインダー: 前回の水分補給から#{hours_since_last_hydration}時間経過しました",
        delivered_at: Time.current
      )
    end

    # アラート通知（1日の目安摂取量未達成）
    if child.hydrations.where('DATE(fed_at) = ?', Date.current).sum(:amount) < child.daily_hydration_goal
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "💧 水分補給",
        message: "アラート: 1日の目安摂取量に達していません",
        delivered_at: Time.current
      )
    end
  end
end
