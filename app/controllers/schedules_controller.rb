class SchedulesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @month = params[:start_date] ? Date.parse(params[:start_date]) : Date.current.beginning_of_month

   # 月のスケジュール（終日→時間順）
   @schedules = current_user.schedules
                        .includes(:children)
                        .order(all_day: :desc, start_time: :desc, id: :desc)

    # 日付ごとにグループ化（JST基準）
    @grouped_schedules = @schedules.group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }

    # スケジュールが存在する日だけ抽出（降順表示）
    @schedule_all_dates = @grouped_schedules.keys.sort.reverse
  end

  def show
    @schedule = current_user.schedules.find(params[:id])
  end

  def new
    now = Time.current
    rounded_time = (now + 1.hour).beginning_of_hour
    @schedule = current_user.schedules.new(start_time: rounded_time, end_time: rounded_time + 1.hour)
    @schedule.child_ids = [ current_child.id ] if current_child.present?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "schedules/form_modal",
          locals: { schedule: @schedule }
        )
      end
    end
  end

  def create
    @schedule = current_user.schedules.new(schedule_params)

    respond_to do |format|
      if @schedule.save
        # 月とスケジュール一覧を再取得（子供・ユーザー予定含む）
        @month = @schedule.start_time.beginning_of_month
        @schedules = current_user.schedules.includes(:children)
                                 .where(start_time: @month.all_month)
                                 .order(start_time: :asc)

        format.html { redirect_to schedules_path, notice: "予定を登録しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 一覧のレコードを置換
            turbo_stream.replace("schedules-container", partial: "schedules/index", locals: { grouped_schedules: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time DESC, id DESC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }, schedule_all_dates: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time ASC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),

            # カレンダーを更新
            turbo_stream.replace("calendar", partial: "schedules/calendar", locals: { month: @month, schedules: @schedules }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "予定を登録しました" } }),

            # ダッシュボードのスケジュール一覧にも追加
            turbo_stream.replace("dashboard-schedules-container", partial: "home/schedules_table_or_empty", locals: { latest_schedules: current_user.schedules.where("start_time >= ?", Time.current).order(start_time: :desc, id: :desc).limit(5) }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
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

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "schedules/form_modal",
          locals: { schedule: @schedule }
        )
      end
    end
  end

  def update
    @schedule = current_user.schedules.find(params[:id])

    respond_to do |format|
      if @schedule.update(schedule_params)
        # 月とスケジュール一覧を再取得（子供・ユーザー予定含む）
        @month = @schedule.start_time.beginning_of_month
        @schedules = current_user.schedules.includes(:children)
                                 .where(start_time: @month.all_month)
                                 .order(start_time: :asc)

        format.html { redirect_to schedules_path, notice: "予定を更新しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 一覧のレコードを置換
            turbo_stream.replace("schedules-container", partial: "schedules/index", locals: { grouped_schedules: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time DESC, id DESC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }, schedule_all_dates: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time ASC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),

            # カレンダーを更新
            turbo_stream.replace("calendar", partial: "schedules/calendar", locals: { month: @month, schedules: @schedules }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "予定を更新しました" } }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-schedules-container", partial: "home/schedules_table_or_empty", locals: { latest_schedules: current_user.schedules.where("start_time >= ?", Time.current).order(start_time: :desc, id: :desc).limit(5) }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
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
    # 月とスケジュール一覧を再取得（子供・ユーザー予定含む）
    @month = Date.current.beginning_of_month
    @schedules = current_user.schedules.includes(:children)
                             .where(start_time: @month.all_month)
                             .order(start_time: :asc)

    respond_to do |format|
      format.html { redirect_to schedules_path, notice: "予定を削除しました" }

      format.turbo_stream do
        render turbo_stream: [
          # 一覧のレコードを置換
          turbo_stream.replace("schedules-container", partial: "schedules/index", locals: { grouped_schedules: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time DESC, id DESC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }, schedule_all_dates: current_user.schedules.includes(:children).order(Arel.sql("all_day DESC, start_time ASC")).group_by { |s| s.start_time.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),

          # カレンダーを更新
          turbo_stream.replace(
            "calendar",
            partial: "schedules/calendar",
            locals: { month: @month, schedules: @schedules }
          ),
          # フラッシュ通知を追加
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "予定を削除しました" } }
          ),

          # ダッシュボードの育児記録一覧にも追加
          turbo_stream.replace("dashboard-schedules-container", partial: "home/schedules_table_or_empty", locals: { latest_schedules: current_user.schedules.where("start_time >= ?", Time.current).order(start_time: :desc, id: :desc).limit(5) }),

          # モーダルを閉じる
          turbo_stream.update("modal") { "" }
        ]
      end
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
    params.require(:schedule).permit(:start_time, :end_time, :title, :all_day, :memo, :user_only, child_ids: [])
  end
end
