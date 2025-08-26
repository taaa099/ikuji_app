class AddDailyHydrationGoalToChildren < ActiveRecord::Migration[8.0]
  def change
    add_column :children, :daily_hydration_goal, :integer, default: 800, null: false
  end
end
