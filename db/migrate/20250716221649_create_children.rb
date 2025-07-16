class CreateChildren < ActiveRecord::Migration[8.0]
  def change
    create_table :children do |t|
      t.string :name
      t.date :birth_date

      t.timestamps
    end
  end
end
