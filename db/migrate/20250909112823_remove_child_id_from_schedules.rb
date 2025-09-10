class RemoveChildIdFromSchedules < ActiveRecord::Migration[8.0]
  def change
    remove_reference :schedules, :child, foreign_key: true
  end
end
