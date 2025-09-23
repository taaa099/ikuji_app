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
  end

  def show
  end

  def new
    @sleep_record = current_child.sleep_records.new(start_time: Time.current)
  end

  def create
    @sleep_record = current_child.sleep_records.new(sleep_records_params.merge(user: current_user))
    if @sleep_record.save
      session.delete(:sleep_record_start_time) # セッションから削除
      redirect_to child_sleep_records_path(current_child), notice: " 睡眠の記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @sleep_record = current_child.sleep_records.find(params[:id])
  end

  def update
    @sleep_record = current_child.sleep_records.find(params[:id])
    if @sleep_record.update(sleep_records_params.merge(user: current_user))
      redirect_to child_sleep_records_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @sleep_record = current_child.sleep_records.find(params[:id])
    @sleep_record.destroy
    redirect_to child_sleep_records_path(current_child), notice: "記録を削除しました"
  end

  def analysis
    # 直近1週間（日曜日始まり）
    @start_date = Date.today.beginning_of_week(:sunday)
    @end_date   = Date.today.end_of_week(:saturday).end_of_day

    # 対象期間のレコード取得
    records = current_child.sleep_records
                           .where.not(start_time: nil, end_time: nil)
                           .where(start_time: @start_date..@end_date)

    # 日別の睡眠時間集計
    @daily_sleep = (0..6).map do |i|
      day = @start_date + i
      day_records = records.select { |r| r.start_time.to_date == day }

      daytime_minutes = day_records.sum do |r|
        if r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
        else
          0
        end
      end

      nighttime_minutes = day_records.sum do |r|
        if !r.start_time.hour.between?(9, 16)
          ((r.end_time - r.start_time)/60).to_i
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

    # 平均睡眠時間（日中・夜）
    daytime_durations = @daily_sleep.map { |d| d[:daytime] }
    nighttime_durations = @daily_sleep.map { |d| d[:nighttime] }

    @average_daytime_sleep = if daytime_durations.any?
                               (daytime_durations.sum / daytime_durations.size.to_f).round(1)
    else
                               0
    end

    @average_nighttime_sleep = if nighttime_durations.any?
                                 (nighttime_durations.sum / nighttime_durations.size.to_f).round(1)
    else
                                 0
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def sleep_records_params
    params.require(:sleep_record).permit(:start_time, :end_time, :memo)
  end
end
