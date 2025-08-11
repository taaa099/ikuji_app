class CreateTemperatures < ActiveRecord::Migration[8.0]
  def change
    create_table :temperatures do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :measured_at
      t.decimal :temperature, precision: 3, scale: 1
      t.text :memo

      t.timestamps
    end
  end
end
