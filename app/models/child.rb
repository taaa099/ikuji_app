class Child < ApplicationRecord
  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy
  has_many :users, through: :user_children

  # 各種育児記録との関連
  has_many :feeds, dependent: :destroy
  has_many :diapers, dependent: :destroy
  has_many :bottles, dependent: :destroy
  has_many :hydrations, dependent: :destroy
  has_many :baby_foods, dependent: :destroy
  has_many :sleep_records, dependent: :destroy
  has_many :temperatures, dependent: :destroy
  has_many :baths, dependent: :destroy
  has_many :vaccinations, dependent: :destroy
  has_many :growths, dependent: :destroy

  # スケジュール機能との関連
  has_many :schedule_children, dependent: :destroy
  has_many :schedules, through: :schedule_children

  # 通知との関連
  has_many :notifications, dependent: :destroy

  # 子どものプロフィール画像を1枚だけ添付できるようにするActiveStorageの設定
  has_one_attached :image

  # 子どもの名前と誕生日は必須項目(名前は30文字まで)
  validates :name, presence: true, length: { maximum: 30 }
  validates :birth_date, presence: true
  validates :gender, presence: true

  # 指定した日付の全育児記録（授乳・おむつ・睡眠など）をまとめて取得し、日時の降順で返す(ダッシュボードの「home#index」で使用)
  def records_for_date(date)
    start_time = date.beginning_of_day
    end_time   = date.end_of_day

    records = []
    date_columns = {
      Feed => :fed_at,
      Diaper => :changed_at,
      Bottle => :given_at,
      Hydration => :fed_at,
      BabyFood => :fed_at,
      SleepRecord => :start_time,
      Temperature => :measured_at,
      Bath => :bathed_at,
      Vaccination => :vaccinated_at
    }

    date_columns.each do |model, col|
      records.concat(send(model.name.underscore.pluralize).where(col => start_time..end_time))
    end

    # 日時降順
    records.sort_by { |r| date_columns[r.class] ? r.send(date_columns[r.class]) : Time.at(0) }.reverse
  end
end
