class CreateGrowths < ActiveRecord::Migration[8.0]
  def change
    create_table :growths do |t|
      t.references :child, null: false, foreign_key: true
      t.float :height
      t.float :weight
      t.float :head_circumference
      t.float :chest_circumference
      t.date :recorded_at

      t.timestamps
    end
  end
end
