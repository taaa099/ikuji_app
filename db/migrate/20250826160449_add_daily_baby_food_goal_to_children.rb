class AddDailyBabyFoodGoalToChildren < ActiveRecord::Migration[8.0]
  def change
    add_column :children, :daily_baby_food_goal, :integer, default: 3, null: false
  end
end