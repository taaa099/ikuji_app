class ChangeMemoToTextInFeeds < ActiveRecord::Migration[8.0]
  def change
    change_column :feeds, :memo, :text
  end
end
