class SleepRecord < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :validate_start_and_end_time_presence

  # 直近1週間（日曜〜土曜）の睡眠集計（homeとanalysisの共通処理）
  def self.weekly_summary_for(child)
    start_date = Date.today.beginning_of_week(:sunday)
    end_date   = start_date + 6.days

    # 今週の記録
    records = child.sleep_records
                   .where.not(start_time: nil, end_time: nil)
                   .where(start_time: start_date.beginning_of_day..end_date.end_of_day)

    daily_sleep = (0..6).map do |i|
      day = start_date + i
      day_records = records.select { |r| r.start_time.to_date == day }

      daytime_minutes = day_records.sum do |r|
        if r.start_time && r.end_time && r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
        else
          0
        end
      end

      nighttime_minutes = day_records.sum do |r|
        if r.start_time && r.end_time && !r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
        else
          0
        end
      end

      {
        date: day.strftime("%m/%d"),
        daytime: daytime_minutes,
        nighttime: nighttime_minutes,
        naps: day_records.count { |r| r.start_time && r.start_time.hour.between?(9, 16) }
      }
    end

    # 今週平均（記録がある日のみで計算）
    daytime_durations = daily_sleep.map { |d| d[:daytime] }.reject(&:zero?)
    nighttime_durations = daily_sleep.map { |d| d[:nighttime] }.reject(&:zero?)

    average_daytime_sleep = daytime_durations.any? ? (daytime_durations.sum.to_f / daytime_durations.size) : 0
    average_nighttime_sleep = nighttime_durations.any? ? (nighttime_durations.sum.to_f / nighttime_durations.size) : 0

    # 前週の差分を計算（記録がある日のみで計算）
    prev_start = start_date - 7.days
    prev_end   = end_date - 7.days
    prev_records = child.sleep_records
                        .where.not(start_time: nil, end_time: nil)
                        .where(start_time: prev_start.beginning_of_day..prev_end.end_of_day)

    prev_daily_sleep = (0..6).map do |i|
      day = prev_start + i
      day_records = prev_records.select { |r| r.start_time.to_date == day }

      daytime_minutes = day_records.sum do |r|
        if r.start_time && r.end_time && r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
        else
          0
        end
      end

      nighttime_minutes = day_records.sum do |r|
        if r.start_time && r.end_time && !r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
        else
          0
        end
      end

      { daytime: daytime_minutes, nighttime: nighttime_minutes }
    end

    prev_daytime_durations = prev_daily_sleep.map { |d| d[:daytime] }.reject(&:zero?)
    prev_nighttime_durations = prev_daily_sleep.map { |d| d[:nighttime] }.reject(&:zero?)

    prev_average_daytime = prev_daytime_durations.any? ? (prev_daytime_durations.sum.to_f / prev_daytime_durations.size) : 0
    prev_average_nighttime = prev_nighttime_durations.any? ? (prev_nighttime_durations.sum.to_f / prev_nighttime_durations.size) : 0

    daytime_change = (average_daytime_sleep - prev_average_daytime).round
    nighttime_change = (average_nighttime_sleep - prev_average_nighttime).round

    {
      start_date: start_date,
      end_date: end_date,
      daily_sleep: daily_sleep,
      average_daytime_sleep: average_daytime_sleep,
      average_nighttime_sleep: average_nighttime_sleep,
      daytime_record_days: daytime_durations.size,
      nighttime_record_days: nighttime_durations.size,
      daytime_change: daytime_change,
      nighttime_change: nighttime_change
    }
  end

private

  def validate_start_and_end_time_presence
    if start_time.blank? && end_time.blank?
      errors.add(:start_time, "を入力してください")
    elsif start_time.blank? && end_time.present?
      errors.add(:start_time, "は必須です。終了時間だけの入力はできません。")
    elsif end_time.present? && start_time.present? && end_time < start_time
      errors.add(:end_time, "は開始時間より後でなければなりません。")
    end
  end
end
