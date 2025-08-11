class CreateBaths < ActiveRecord::Migration[8.0]
  def change
    create_table :baths do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :bathed_at
      t.string :bath_type
      t.text :memo

      t.timestamps
    end
  end
end
