class AddUserToMultipleModels < ActiveRecord::Migration[8.0]
  def change
    # 対象テーブルを配列でまとめる
    tables = [
      :diapers,
      :bottles,
      :hydrations,
      :baby_foods,
      :sleep_records,
      :temperatures,
      :baths,
      :vaccinations
    ]

    tables.each do |table|
      unless column_exists?(table, :user_id)
        add_reference table, :user, null: true, foreign_key: true
      end
    end
  end
end