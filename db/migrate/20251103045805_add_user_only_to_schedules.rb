class AddUserOnlyToSchedules < ActiveRecord::Migration[8.0]
  def change
    add_column :schedules, :user_only, :boolean, default: false, null: false
  end
end
