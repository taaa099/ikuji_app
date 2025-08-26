class BabyFood < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :validate_amount
  validates :fed_at, presence: true

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
    # リマインダー（簡易版: 前回から6時間以上経過したら）
    last_food = child.baby_foods.where.not(id: id).order(fed_at: :desc).first
    if last_food
      hours_since_last = ((self.fed_at - last_food.fed_at) / 1.hour).round(1)
      if hours_since_last >= 6
        Notification.create!(
          user: user,
          child: child,
          target: self,
          notification_kind: :reminder,
          title: "👶 離乳食",
          message: "リマインダー: 本日の離乳食時間です",
          delivered_at: Time.current
        )
      end
    end

    # 今日の食事回数
    today_count = child.baby_foods.where("DATE(fed_at) = ?", Date.current).count

    #  目標未達成かつ、今回でちょうど未達の状態のときのみ通知
    if today_count < child.daily_baby_food_goal &&
       today_count == child.daily_baby_food_goal - 1
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "👶 離乳食",
        message: "アラート: 1日#{child.daily_baby_food_goal}回の食事が未達成です",
        delivered_at: Time.current
      )
    end
  end
end
