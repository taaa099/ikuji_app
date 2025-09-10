class SchedulesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @month = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_month

    # 今月分のスケジュール（カレンダー表示用）
    @schedules = current_user.schedules.includes(:children)
                            .where(start_time: @month.all_month)
                            .order(start_time: :asc)

  # 一覧テーブル用
  @all_schedules = current_user.schedules.includes(:children).order(start_time: :desc)
  end

  def show
    @schedule = current_user.schedules.find(params[:id])
  end

  def new
    now = Time.current
    rounded_time = (now + 1.hour).beginning_of_hour
    @schedule = current_user.schedules.new(start_time: rounded_time, end_time: rounded_time + 1.hour)

    # 現在選択中の子供を初期値に設定
    @schedule.child_ids = [ current_child.id ] if current_child.present?
  end

  def create
      @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      redirect_to schedules_path, notice: "予定を登録しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @schedule = current_user.schedules.find(params[:id])
  end

  def update
    @schedule = current_user.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      redirect_to schedules_path, notice: "予定を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @schedule = current_user.schedules.find(params[:id])
    @schedule.destroy
      redirect_to schedules_path, notice: "予定を削除しました"
  end

  private

 # フォームから送信されたパラメータのうち、許可するキーを指定
 def schedule_params
  params.require(:schedule).permit(:start_time, :end_time, :title, :all_day, :repeat, :memo, child_ids: [])
 end
end
