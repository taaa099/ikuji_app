class SleepRecordNotificationService
  REMINDER_HOURS = [ 3, 4 ]        # リマインダー時間帯（3時間・4時間経過）
  SHORT_SLEEP_MINUTES = 30       # 短すぎる睡眠の閾値（分）
  LONG_SLEEP_HOURS = 4           # 長すぎる睡眠の閾値（時間）

  def self.create_notifications_for(child)
    # --- リマインダー ---
    latest_sleep = child.sleep_records.order(end_time: :desc, start_time: :desc).first
    return if latest_sleep.nil? || latest_sleep.start_time.nil? # start_timeもなければスキップ
    reference_time = latest_sleep.end_time || latest_sleep.start_time

    # 未来の時刻ならスキップ
    return if reference_time > Time.current

    # 昼寝区分（9時〜16時）の場合のみリマインダー作成
    if reference_time.hour.between?(9, 16)
      hours_since_last_sleep = ((Time.current - reference_time) / 1.hour).floor
      REMINDER_HOURS.each do |hour|
        next unless hours_since_last_sleep == hour

        # 同じレコード・同じ種類の通知が既にあるかチェック
        notification_exists = Notification.exists?(
          child: child,
          target: latest_sleep,
          target_type: "SleepRecord",
          notification_kind: :reminder
        )
        next if notification_exists

        message_prefix = "昼寝"
        Notification.create!(
          user: latest_sleep.user || child.user,
          child: child,
          target: latest_sleep,
          target_type: "SleepRecord",
          notification_kind: :reminder,
          title: "🛌 睡眠",
          message: "リマインダー: #{message_prefix}の前回の睡眠から#{hour}時間起きています",
          delivered_at: Time.current
        )
      end
    end

    # --- アラート（昼寝のみ、当日）---
    today_sleeps = child.sleep_records.where("DATE(start_time) = ?", Date.current)
                                     .where.not(start_time: nil, end_time: nil)

    today_sleeps.each do |sleep|
      next if sleep.end_time.nil? # end_timeがない場合はスキップ（計算不可）

      # 未来の end_time の場合は通知しない
      next if sleep.end_time > Time.current

      is_daytime = sleep.start_time.hour.between?(9, 16)
      next unless is_daytime # 昼寝以外はアラート出さない

      duration_minutes = ((sleep.end_time - sleep.start_time) / 60).to_i
      duration_str = duration_minutes >= 60 ? "#{(duration_minutes / 60.0).round(1)}時間" : "#{duration_minutes}分"
      message_prefix = "昼寝"

      # 開始・終了時刻をフォーマット
      start_str = sleep.start_time.strftime("%H:%M")
      end_str   = sleep.end_time.strftime("%H:%M")

      alert_message = if duration_minutes < SHORT_SLEEP_MINUTES
                        "アラート: 本日の#{message_prefix}（#{start_str}〜#{end_str}）は#{duration_str}で、やや短めです"
      elsif duration_minutes >= LONG_SLEEP_HOURS * 60
                        "アラート: 本日の#{message_prefix}（#{start_str}〜#{end_str}）は#{duration_str}で、やや長めです"
      else
                        next # 正常範囲なら通知不要
      end

      # 同じレコード・同じ種類の通知が既にあるかチェック
      notification_exists = Notification.exists?(
        child: child,
        target: sleep,
        target_type: "SleepRecord",
        notification_kind: :alert
      )
      next if notification_exists

      Notification.create!(
        user: sleep.user || child.user,
        child: child,
        target: sleep,
        target_type: "SleepRecord",
        notification_kind: :alert,
        title: "🛌 睡眠",
        message: alert_message,
        delivered_at: Time.current
      )
    end
  rescue => e
    Rails.logger.error("SleepRecordNotificationService error for child_id=#{child.id}: #{e.message}")
  end
end
