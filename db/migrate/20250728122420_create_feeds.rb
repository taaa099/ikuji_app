class CreateFeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :feeds do |t|
      t.references :child, null: false, foreign_key: true
      t.integer :left_time
      t.integer :right_time
      t.datetime :fed_at
      t.string :memo

      t.timestamps
    end
  end
end
