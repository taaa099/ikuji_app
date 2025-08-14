class HomeController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    records = []
  # モデルごとに基準日時カラム名を定義
  date_columns = {
    Feed => :fed_at,
    Diaper => :changed_at,
    Bottle => :given_at,
    Hydration => :fed_at,
    BabyFood => :fed_at,
    SleepRecord => :start_time,
    Temperature => :measured_at,
    Bath => :bathed_at,
    Vaccination => :vaccinated_at
  }

  # 全モデルのレコードを取得し配列に追加
  date_columns.each do |model, date_col|
    next unless current_child
    records += current_child.send(model.name.underscore.pluralize)
  end

  # ソートはカラム名を動的に参照
  @records = records.sort_by do |record|
    col = date_columns[record.class]
    record.send(col) || Time.at(0)  # nilなら最古扱いに
  end.reverse # 新しい順
  end
end
