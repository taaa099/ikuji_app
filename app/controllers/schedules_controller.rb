class SchedulesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @month = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    @schedules = current_user.schedules.includes(:children)
                             .where(start_time: @month.all_month)
                             .order(start_time: :asc)
    @all_schedules = current_user.schedules.includes(:children).order(start_time: :desc)

    respond_to do |format|
      format.html # 普通の表示
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "calendar",
          partial: "schedules/calendar",
          locals: { month: @month, schedules: @schedules }
        )
      end
    end
  end

  def show
    @schedule = current_user.schedules.find(params[:id])
  end

  def new
    now = Time.current
    rounded_time = (now + 1.hour).beginning_of_hour
    @schedule = current_user.schedules.new(start_time: rounded_time, end_time: rounded_time + 1.hour)
    @schedule.child_ids = [ current_child.id ] if current_child.present?
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)
    if @schedule.save
      @month = @schedule.start_time.beginning_of_month
      @schedules = current_user.schedules.includes(:children)
                               .where(start_time: @month.all_month)
                               .order(start_time: :asc)

      respond_to do |format|
        format.html { redirect_to schedules_path, notice: "予定を登録しました" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "schedules/form_modal",
            locals: { schedule: @schedule }
          )
        end
      end
    end
  end

  def edit
    @schedule = current_user.schedules.find(params[:id])
  end

  def update
    @schedule = current_user.schedules.find(params[:id])
    if @schedule.update(schedule_params)
      @month = @schedule.start_time.beginning_of_month
      @schedules = current_user.schedules.includes(:children)
                               .where(start_time: @month.all_month)
                               .order(start_time: :asc)

      respond_to do |format|
        format.html { redirect_to schedules_path, notice: "予定を更新しました" }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "schedules/form_modal",
            locals: { schedule: @schedule }
          )
        end
      end
    end
  end

  def destroy
    @schedule = current_user.schedules.find(params[:id])
    @schedule.destroy

    @month = Date.current.beginning_of_month
    @schedules = current_user.schedules.includes(:children)
                             .where(start_time: @month.all_month)
                             .order(start_time: :asc)

    respond_to do |format|
      format.html { redirect_to schedules_path, notice: "予定を削除しました" }
      format.turbo_stream
    end
  end

  def calendar
    @month = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_month
    @schedules = current_user.schedules.includes(:children)
                            .where(start_time: @month.all_month)
                            .order(start_time: :asc)
    render partial: "schedules/calendar"
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def schedule_params
    params.require(:schedule).permit(:start_time, :end_time, :title, :all_day, :repeat, :memo, child_ids: [])
  end
end