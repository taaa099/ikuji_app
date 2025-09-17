class CreateNotificationSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :notification_settings do |t|
      t.references :user, null: false, foreign_key: true
      t.string :target_type, null: false  # "Feed", "Diaper", "Bottle", ...

      # 時間経過系
      t.integer :reminder_after   # 例: 180分後にリマインド
      t.integer :alert_after      # 例: 300分以上空いたらアラート

      # しきい値系（体温など）
      t.decimal :alert_threshold, precision: 5, scale: 2  # 例: 37.5℃

      # ON/OFF
      t.boolean :reminder_on, default: false, null: false
      t.boolean :alert_on, default: false, null: false

      # 時刻指定（予定やワクチン用）
      t.time :alert_time

      # 拡張用（睡眠のmin_hours/max_hoursなど）
      t.json :extra_settings

      t.timestamps
    end
  end
end
