class Diaper < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :at_least_one_selected
  validates :changed_at, presence: true

  private

  def at_least_one_selected
    unless pee || poop
     errors.add(:base, "おしっこ、うんちのいずれかを選択してください")
    end
  end

  def create_default_notification
    last_diaper = child.diapers.where.not(id: id).order(changed_at: :desc).first
    return unless last_diaper

    hours_since_last_change = ((self.changed_at - last_diaper.changed_at) / 1.hour).round(1)

    # リマインダー通知
    if hours_since_last_change >= 3 && hours_since_last_change < 5
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "💩 おむつ",
        message: "リマインダー: 前回のオムツ交換から#{hours_since_last_change}時間経過しました",
        delivered_at: Time.current
      )
    end

    # アラート通知
    if hours_since_last_change >= 5
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "💩 おむつ",
        message: "アラート: #{hours_since_last_change}時間以上交換されていません",
        delivered_at: Time.current
      )
    end
  end
end
