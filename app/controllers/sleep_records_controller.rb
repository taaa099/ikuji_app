class SleepRecordsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!
  before_action :ensure_child_selected

  def index
    @sleep_records = current_child.sleep_records

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
    sleep_stats = SleepRecord.weekly_summary_for(current_child)
    @start_date = sleep_stats[:start_date]
    @end_date = sleep_stats[:end_date]
    @daily_sleep = sleep_stats[:daily_sleep]
    @average_daytime_sleep = sleep_stats[:average_daytime_sleep]
    @average_nighttime_sleep = sleep_stats[:average_nighttime_sleep]
    @daytime_record_days = sleep_stats[:daytime_record_days]
    @nighttime_record_days = sleep_stats[:nighttime_record_days]
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def sleep_record_params
    params.require(:sleep_record).permit(:start_time, :end_time, :memo)
  end
end
