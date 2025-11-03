class SleepRecordsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @sleep_records = current_child.sleep_records

    # 並び順指定
    @sleep_records = case params[:sort]
    when "date_desc"
      @sleep_records.order(start_time: :desc)
    when "date_asc"
      @sleep_records.order(start_time: :asc)
    else
      @sleep_records.order(start_time: :desc)
    end

    # ==== 全日程取得 ====
    if @sleep_records.any?
      sleep_record_start_date = @sleep_records.minimum(:start_time).in_time_zone("Tokyo").to_date
      sleep_record_end_date   = [ @sleep_records.maximum(:start_time).in_time_zone("Tokyo").to_date, Date.current ].max
      @sleep_record_all_dates = (sleep_record_start_date..sleep_record_end_date).to_a.reverse # 新しい日付が上
    else
      @sleep_record_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_sleep_records = @sleep_records.group_by { |f| f.start_time.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    @sleep_record = current_child.sleep_records.new(start_time: Time.current)
  end

  def create
    @sleep_record = current_child.sleep_records.new(sleep_record_params.merge(user: current_user))

    respond_to do |format|
      if @sleep_record.save
         # start_time を基準に selected_date をセット
         @selected_date = @sleep_record.start_time.to_date

        session.delete(:sleep_record_start_time) # セッションから削除
        format.html { redirect_to child_sleep_records_path(current_child), notice: "睡眠の記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("sleep_records-container", partial: "sleep_records/index", locals: { sleep_records: current_child.sleep_records.order(start_time: :desc), grouped_sleep_records: current_child.sleep_records.group_by { |f| f.start_time.to_date }, sleep_record_all_dates: (current_child.sleep_records.any? ? (current_child.sleep_records.minimum(:start_time).to_date..[ current_child.sleep_records.maximum(:start_time).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "睡眠の記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "sleep_records/form_modal",
            locals: { sleep_record: @sleep_record }
          )
        end
      end
    end
  end

  def edit
    @sleep_record = current_child.sleep_records.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "sleep_records/form_modal",
          locals: { sleep_record: @sleep_record }
        )
      end
    end
  end

  def update
    @sleep_record = current_child.sleep_records.find(params[:id])
    sleep_record_old_date = @sleep_record.start_time.to_date

    respond_to do |format|
      if @sleep_record.update(sleep_record_params.merge(user: current_user))
        sleep_record_new_date = @sleep_record.start_time.to_date
         # start_time を基準に selected_date をセット
         @selected_date = @sleep_record.start_time.to_date

        format.html { redirect_to child_sleep_records_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("sleep_records-container", partial: "sleep_records/index", locals: { sleep_records: current_child.sleep_records.order(start_time: :desc), grouped_sleep_records: current_child.sleep_records.group_by { |f| f.start_time.to_date }, sleep_record_all_dates: (current_child.sleep_records.any? ? (current_child.sleep_records.minimum(:start_time).to_date..[ current_child.sleep_records.maximum(:start_time).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),

            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "sleep_records/form_modal",
            locals: { sleep_record: @sleep_record }
          )
        end
      end
    end
  end

  def destroy
    @sleep_record = current_child.sleep_records.find(params[:id])
    @sleep_record.destroy
    # start_time を基準に selected_date をセット
    @selected_date = @sleep_record.start_time.to_date

    respond_to do |format|
      format.html { redirect_to child_sleep_records_path(current_child), notice: "記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("sleep_records-container", partial: "sleep_records/index", locals: { sleep_records: current_child.sleep_records.order(start_time: :desc), grouped_sleep_records: current_child.sleep_records.group_by { |f| f.start_time.to_date }, sleep_record_all_dates: (current_child.sleep_records.any? ? (current_child.sleep_records.minimum(:start_time).to_date..[ current_child.sleep_records.maximum(:start_time).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

def analysis
  # 直近1週間（日曜〜土曜）
  @start_date = Date.today.beginning_of_week(:sunday)
  @end_date   = Date.today.end_of_week(:saturday)

  records = current_child.sleep_records
                         .where.not(start_time: nil, end_time: nil)
                         .where(start_time: @start_date.beginning_of_day..@end_date.end_of_day)

  @daily_sleep = (0..6).map do |i|
    day = @start_date + i
    day_records = records.select { |r| r.start_time.to_date == day }

    daytime_minutes = day_records.sum do |r|
      if r.start_time.hour.between?(9, 16)
        ((r.end_time - r.start_time) / 60).to_i
      else
        0
      end
    end

    nighttime_minutes = day_records.sum do |r|
      unless r.start_time.hour.between?(9, 16)
        ((r.end_time - r.start_time) / 60).to_i
      else
        0
      end
    end

    {
      date: day.strftime("%m/%d"),
      daytime: daytime_minutes,
      nighttime: nighttime_minutes,
      naps: day_records.count { |r| r.start_time.hour.between?(9, 16) }
    }
  end

  # 平均睡眠時間（日中・夜）※記録がある日のみで平均を出す
  daytime_durations = @daily_sleep.map { |d| d[:daytime] }.reject(&:zero?)
  nighttime_durations = @daily_sleep.map { |d| d[:nighttime] }.reject(&:zero?)

  @average_daytime_sleep = if daytime_durations.any?
                             daytime_durations.sum.to_f / daytime_durations.size
  else
                             0
  end

  @average_nighttime_sleep = if nighttime_durations.any?
                               nighttime_durations.sum.to_f / nighttime_durations.size
  else
                               0
  end

  # ✅ 昼・夜それぞれの記録日数
  @daytime_record_days = daytime_durations.size
  @nighttime_record_days = nighttime_durations.size
end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def sleep_record_params
    params.require(:sleep_record).permit(:start_time, :end_time, :memo)
  end
end
