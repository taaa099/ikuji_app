class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :child, null: false, foreign_key: true
      t.string :target_type
      t.bigint :target_id
      t.integer :notification_type, null: false
      t.string :title, null: false
      t.text :message
      t.boolean :read, default: false, null: false
      t.datetime :delivered_at

      t.timestamps
    end

    add_index :notifications, [ :target_type, :target_id ]
    add_index :notifications, [ :user_id, :read ]
    add_index :notifications, [ :child_id, :notification_type ]
  end
end
