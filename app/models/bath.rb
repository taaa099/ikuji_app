class Bath < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :bathed_at, presence: true
  validates :bath_type, presence: true

  private

  def create_default_notification
    # リマインダー: 今日の入浴確認
    today_baths = child.baths.where(bathed_at: Time.zone.today.all_day)
    today_baths = today_baths.where.not(id: id) if persisted?
    unless today_baths.exists?
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "🛁 お風呂",
        message: "リマインダー: 今日のお風呂時間です",
        delivered_at: Time.current
      )
    end

    # アラート: 2日以上入浴がない場合
    last_bath = child.baths.where.not(id: id).order(bathed_at: :desc).first
    if last_bath
      days_since_last_bath = (bathed_at.to_date - last_bath.bathed_at.to_date).to_i
      if days_since_last_bath >= 2
        Notification.create!(
          user: user,
          child: child,
          target: self,
          notification_kind: :alert,
          title: "🛁 お風呂",
          message: "アラート: 2日以上入浴記録がありません",
          delivered_at: Time.current
        )
      end
    else
      #  記録なしならアラート
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "🛁 お風呂",
        message: "アラート: 入浴記録がありません",
        delivered_at: Time.current
      )
    end
  end
end
