class HomeController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    records = []

    # ① 現在の日付（またはURLパラメータ）
    @selected_date = params[:date] ? Date.parse(params[:date]) : Date.current
    start_time = @selected_date.beginning_of_day
    end_time   = @selected_date.end_of_day

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

    # 各モデルの日付範囲内レコードを取得
    date_columns.each do |model, date_col|
      next unless current_child
      model_records = current_child.send(model.name.underscore.pluralize)
                          .where(date_col => start_time..end_time)
      records.concat(model_records)
    end

    # ソートはカラム名を動的に参照し、新しい順に並べる
    @records = records.sort_by do |record|
      col = date_columns[record.class]
      record.send(col) || Time.at(0)  # nilなら最古扱い
    end.reverse

    # スケジュール一覧を取得（直近の予定が過ぎていない最大5件）
    @latest_schedules = current_user.schedules.where("start_time >= ?", Time.current).order(start_time: :desc).limit(5)

    # ----- 今週の記録数（育児記録） -----
    if current_child
      start_of_week = Date.current.beginning_of_week(:sunday)
      end_of_week   = Date.current.end_of_week(:saturday)

      start_of_last_week = start_of_week - 7.days
      end_of_last_week   = end_of_week - 7.days

      # 集計対象モデルと日時カラム
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

      # 今週の件数
      this_week_records = []
      date_columns.each do |model, col|
        this_week_records.concat(current_child.send(model.name.underscore.pluralize)
                                           .where(col => start_of_week..end_of_week))
      end
      @weekly_records_count = this_week_records.size

      # 先週の件数
      last_week_records = []
      date_columns.each do |model, col|
        last_week_records.concat(current_child.send(model.name.underscore.pluralize)
                                            .where(col => start_of_last_week..end_of_last_week))
      end
      last_week_count = last_week_records.size

      # 先週比（%）
      @weekly_change = if last_week_count > 0
                         ((@weekly_records_count - last_week_count) / last_week_count.to_f * 100).round(1)
      else
                         0
      end
    end

    # ----- 成長記録（グラフ用） -----
    if current_child
      @growths = current_child.growths.order(:recorded_at)
      @growths_for_chart = @growths.map do |g|
        # 誕生日からの月齢計算
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

        # 最新身長・体重
        @latest_height = last.height
        @latest_weight = last.weight

        # 前回との差分
        @height_diff = prev ? last.height - prev.height : 0
        @weight_diff = prev ? last.weight - prev.weight : 0

        # 平均身長・体重
        @avg_height = @growths.average(:height).to_f.round(1)
        @avg_weight = @growths.average(:weight).to_f.round(1)
      end
    end

    # Turbo Stream リクエストに対応
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
