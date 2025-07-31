class CreateDiapers < ActiveRecord::Migration[8.0]
  def change
    create_table :diapers do |t|
      t.boolean :pee
      t.boolean :poop
      t.datetime :changed_at
      t.text :memo
      t.references :child, null: false, foreign_key: true

      t.timestamps
    end
  end
end
