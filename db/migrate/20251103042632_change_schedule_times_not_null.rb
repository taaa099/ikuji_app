class ChangeScheduleTimesNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :schedules, :start_time, false
    change_column_null :schedules, :end_time, false
  end
end
