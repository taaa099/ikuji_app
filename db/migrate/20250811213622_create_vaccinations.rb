class CreateVaccinations < ActiveRecord::Migration[8.0]
  def change
    create_table :vaccinations do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :vaccinated_at
      t.string :vaccine_name
      t.text :memo

      t.timestamps
    end
  end
end
