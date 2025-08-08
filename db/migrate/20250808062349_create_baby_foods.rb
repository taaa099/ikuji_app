class CreateBabyFoods < ActiveRecord::Migration[8.0]
  def change
    create_table :baby_foods do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :fed_at
      t.integer :amount
      t.text :memo

      t.timestamps
    end
  end
end
