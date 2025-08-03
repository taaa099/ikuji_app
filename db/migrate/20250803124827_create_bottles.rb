class CreateBottles < ActiveRecord::Migration[8.0]
  def change
    create_table :bottles do |t|
      t.integer :amount
      t.datetime :given_at
      t.text :memo
      t.references :child, null: false, foreign_key: true

      t.timestamps
    end
  end
end
