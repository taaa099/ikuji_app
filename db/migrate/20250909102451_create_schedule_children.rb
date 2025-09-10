class CreateScheduleChildren < ActiveRecord::Migration[8.0]
  def change
    create_table :schedule_children do |t|
      t.references :schedule, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: true

      t.timestamps
    end
  end
end
