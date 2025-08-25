class AddUserToFeeds < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:feeds, :user_id)
      add_reference :feeds, :user, null: false, foreign_key: true
    end
  end
end
