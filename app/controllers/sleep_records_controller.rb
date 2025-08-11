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
    @sleep_record = current_child.sleep_records.new(sleep_records_params)
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
    if @sleep_record.update(sleep_records_params)
      redirect_to child_sleep_records_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def sleep_records_params
    params.require(:sleep_record).permit(:start_time, :end_time, :memo)
  end
end
