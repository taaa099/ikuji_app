class Vaccination < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :vaccinated_at, presence: true
  validates :vaccine_name, presence: true

  private

  def create_default_notification
    return unless vaccinated_at

    today = Time.zone.today
    days_until_vaccination = (vaccinated_at.to_date - today).to_i

    # リマインダー: 3日前
    if days_until_vaccination == 3
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :reminder,
        title: "💉 予防接種",
        message: "リマインダー: 予防接種日まであと3日です (#{vaccine_name})",
        delivered_at: Time.current
      )
    end

    # アラート: 当日
    if days_until_vaccination == 0
      Notification.create!(
        user: user,
        child: child,
        target: self,
        notification_kind: :alert,
        title: "💉 予防接種",
        message: "アラート: 今日は予防接種予定日です (#{vaccine_name})",
        delivered_at: Time.current
      )
    end
  end
end
