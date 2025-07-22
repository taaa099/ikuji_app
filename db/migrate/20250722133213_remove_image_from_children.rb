class RemoveImageFromChildren < ActiveRecord::Migration[8.0]
  def change
    remove_column :children, :image, :string
  end
end
