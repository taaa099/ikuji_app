class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  after_create :create_default_notification_settings

  # Deviseの認証機能
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  attr_accessor :skip_password_validation

  validate :password_required_for_password_tab, on: :update

  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy

  # 実際に使いたいChildとの関連
  has_many :children, through: :user_children

  # スケジュールとの関連
  has_many :schedules, dependent: :destroy
  has_many :schedule_children, through: :schedules

  # 通知との関連
  has_many :notifications, dependent: :destroy
  has_many :notification_settings, dependent: :destroy

  # 日記との関連
  has_many :diaries, dependent: :destroy

  # Avatar（ActiveStorage）
  has_one_attached :avatar

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }

  private

  def password_required_for_password_tab
    return if skip_password_validation
    return unless @current_tab == "password"

    if password.blank? || password_confirmation.blank?
      errors.add(:password, "を入力してください")
    end
    if current_password.blank? || !valid_password?(current_password)
      errors.add(:current_password, "が正しくありません")
    end
  end

  def create_default_notification_settings
    NotificationSetting.target_types.keys.each do |type|
      defaults = case type
      when "feed"
                   {
                     reminder_after: 3,     # 3時間経過でリマインダー
                     alert_after: 5,        # 5時間経過でアラート
                     alert_threshold: nil,
                     reminder_on: true,
                     alert_on: true,
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "diaper"
                   {
                     reminder_after: 3,     # 3時間経過でリマインダー
                     alert_after: 6,        # 6時間経過でアラート
                     alert_threshold: nil,
                     reminder_on: true,
                     alert_on: true,
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "bottle"
                   {
                     reminder_after: 3,   # 時間経過リマインダーなし
                     alert_after: nil,      # 時間経過アラートなし
                     alert_threshold: nil,
                     reminder_on: true,     # オン/オフのみ
                     alert_on: true,        # daily_bottle_goal に基づく
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "hydration"
                   {
                     reminder_after: 3,
                     alert_after: nil,
                     alert_threshold: nil,
                     reminder_on: true,     # オン/オフのみ
                     alert_on: true,        # daily_hydration_goal に基づく
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "baby_food"
                   {
                     reminder_after: nil,   # 時間経過なし、固定時間帯で通知
                     alert_after: nil,
                     alert_threshold: nil,
                     reminder_on: true,     # オン/オフのみ
                     alert_on: true,        # daily_baby_food_goal に基づく
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "sleep_record"
                   {
                     reminder_after: 3,    # 前回の睡眠から◯時間経過
                     alert_after: nil,
                     alert_threshold: nil,
                     reminder_on: true,
                     alert_on: true,        # オン/オフのみ
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "temperature"
                   {
                     reminder_after: nil,
                     alert_after: nil,
                     alert_threshold: 37.6, # 閾値のみ
                     reminder_on: false,     # リマインダーなし
                     alert_on: true,
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "bath"
                   {
                     reminder_after: nil,
                     alert_after: 2,       # 2日経過でアラート
                     alert_threshold: nil,
                     reminder_on: true,      # オン/オフのみ
                     alert_on: true,
                     alert_time: nil,
                     extra_setting: nil
                   }
      when "vaccination"
                   {
                     reminder_after: 3,
                     alert_after: nil,
                     alert_threshold: nil,
                     reminder_on: true,
                     alert_on: true,
                     alert_time: "08:00",    # 通知時刻指定
                     extra_setting: nil
                   }
      when "schedule"
                   {
                     reminder_after: 3,
                     alert_after: nil,
                     alert_threshold: nil,
                     reminder_on: true,
                     alert_on: true,
                     alert_time: "08:00",    # 通知時刻指定
                     extra_setting: nil
                   }
      end

      self.notification_settings.create!(
        target_type: type,
        **defaults
      )
    end
  end
end
