class CreateSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :schedules do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.string :title
      t.boolean :all_day, default: false, null: false
      t.string :repeat, default: "none"
      t.text :memo

      t.timestamps
    end
  end
end
