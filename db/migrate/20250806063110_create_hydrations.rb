class CreateHydrations < ActiveRecord::Migration[8.0]
  def change
    create_table :hydrations do |t|
      t.string :drink_type
      t.datetime :fed_at
      t.text :memo
      t.references :child, null: false, foreign_key: true

      t.timestamps
    end
  end
end
