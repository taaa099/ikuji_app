class AddGenderAndImageToChildren < ActiveRecord::Migration[8.0]
  def change
    add_column :children, :gender, :string
    add_column :children, :image, :string
  end
end
