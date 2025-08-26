class AddDailyBottleGoalToChildren < ActiveRecord::Migration[8.0]
  def change
    add_column :children, :daily_bottle_goal, :integer, default: 600, null: false
  end
end
