class CreateDiaries < ActiveRecord::Migration[8.0]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :content
      t.date :date

      t.timestamps
    end
  end
end
