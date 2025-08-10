class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :child, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.text :memo

      t.timestamps
    end
  end
end
