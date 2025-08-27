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

    # スケジュール一覧を取得（直近5件）
    @schedules = current_child&.schedules&.order(start_time: :desc)&.limit(5) || []

    # ----- 成長記録（グラフ用） -----
    @growths = current_child.growths.order(:recorded_at)
    @growths_for_chart = @growths.map do |g|
      months = (g.recorded_at.year * 12 + g.recorded_at.month) -
               (current_child.birth_date.year * 12 + current_child.birth_date.month)
      months -= 1 if g.recorded_at.day < current_child.birth_date.day

      { 
        recorded_at: g.recorded_at.strftime("%Y-%m-%d"),
        height: g.height,
        weight: g.weight,
        month_age: months
      }
    end

    # ----- 簡易分析 -----
    if @growths.any?
      last = @growths.last
      prev = @growths[-2]

      @latest_height = last.height
      @latest_weight = last.weight

      @height_diff = prev ? last.height - prev.height : 0
      @weight_diff = prev ? last.weight - prev.weight : 0

      @avg_height = @growths.average(:height).to_f.round(1)
      @avg_weight = @growths.average(:weight).to_f.round(1)
    end
  end
end
