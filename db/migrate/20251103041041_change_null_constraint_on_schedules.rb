class ChangeNullConstraintOnSchedules < ActiveRecord::Migration[8.0]
  def change
    change_column_null :schedules, :start_time, true
    change_column_null :schedules, :end_time, true
  end
end
