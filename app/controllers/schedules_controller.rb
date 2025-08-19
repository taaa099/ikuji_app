class SchedulesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @schedules = current_child.schedules.order(:start_time)
  end

  def show
    @schedule = current_child.schedules.find(params[:id])
  end

  def new
    now = Time.current
    rounded_time = (now + 1.hour).beginning_of_hour
    @schedule = current_child.schedules.new(start_time: rounded_time, end_time: rounded_time + 1.hour)
  end

  def create
      @schedule = current_child.schedules.new(schedule_params)
    if @schedule.save
      redirect_to child_schedules_path(current_child), notice: "予定を登録しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @schedule = current_child.schedules.find(params[:id])
  end

  def update
    @schedule = current_child.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to child_schedules_path(current_child), notice: "予定を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule = current_child.schedules.find(params[:id])
    @schedule.destroy
      redirect_to child_schedules_path(current_child), notice: "予定を削除しました"
  end

  private

 # フォームから送信されたパラメータのうち、許可するキーを指定
 def schedule_params
  params.require(:schedule).permit(:start_time, :end_time, :title, :all_day, :repeat, :memo)
 end
end
