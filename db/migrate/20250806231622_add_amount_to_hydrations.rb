class AddAmountToHydrations < ActiveRecord::Migration[8.0]
  def change
    add_column :hydrations, :amount, :integer
  end
end
