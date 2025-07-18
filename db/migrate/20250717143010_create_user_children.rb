class CreateUserChildren < ActiveRecord::Migration[8.0]
  def change
    create_table :user_children do |t|
      t.references :user, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_children, [ :user_id, :child_id ], unique: true
  end
end
