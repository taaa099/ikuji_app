class SleepRecordsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @sleep_records = current_child.sleep_records.order(start_time: :desc)
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
      redirect_to child_sleep_records_path(current_child), notice: " 離乳食の記録を保存しました"
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
    # 直近週（日曜日始まり）
    @start_date = Date.today.beginning_of_week(:sunday)
    @end_date   = Date.today.end_of_week(:saturday).end_of_day

    # 対象期間のレコード取得
    records = current_child.sleep_records
                           .where.not(start_time: nil, end_time: nil)
                           .where(start_time: @start_date..@end_date)

    # 平均睡眠時間（分）
    durations = records.map do |r|
      ((r.end_time - r.start_time) / 60).to_i
    end

    @average_sleep_minutes = if durations.any?
      (durations.sum / durations.size.to_f).round(1)
    else
      0
    end

    # 週別合計睡眠時間（◯月第◯週表記）
    @weekly_sleep = records.group_by { |r| r.start_time.beginning_of_week(:sunday).to_date }
                           .transform_keys { |d| "#{d.month}月第#{((d.day - 1)/7 + 1)}週" }
                           .transform_values do |arr|
      arr.sum { |r| ((r.end_time - r.start_time)/60).to_i }
    end

    # 昼寝パターン（日中 09:00〜17:00）
    @daytime_naps = records.count { |r| r.start_time.hour.between?(9,16) }
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def sleep_records_params
    params.require(:sleep_record).permit(:start_time, :end_time, :memo)
  end
end
