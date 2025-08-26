class AddUserToSchedules < ActiveRecord::Migration[8.0]
  def change
    # schedules テーブルに user_id カラムが存在しなければ追加
    unless column_exists?(:schedules, :user_id)
      add_reference :schedules, :user, null: true, foreign_key: true
    end
  end
end
