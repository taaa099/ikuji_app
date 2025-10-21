class TemperaturesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @temperatures = current_child.temperatures

    # 並び順指定
    @temperatures = case params[:sort]
    when "date_desc"
      @temperatures.order(measured_at: :desc)
    when "date_asc"
      @temperatures.order(measured_at: :asc)
    else
      @temperatures.order(measured_at: :desc)
    end

    # ==== 全日程取得 ====
    if @temperatures.any?
      temperature_start_date = @temperatures.minimum(:measured_at).in_time_zone("Tokyo").to_date
      temperature_end_date   = [ @temperatures.maximum(:measured_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @temperature_all_dates = (temperature_start_date..temperature_end_date).to_a.reverse # 新しい日付が上
    else
      @temperature_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_temperatures = @temperatures.group_by { |f| f.measured_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    # インスタンス生成＋現在時刻取得（測定日時）
    @temperature = current_child.temperatures.new(measured_at: Time.current)
  end

  def create
    @temperature = current_child.temperatures.new(temperature_params.merge(user: current_user))

    respond_to do |format|
      if @temperature.save
         # measured_at を基準に selected_date をセット
         @selected_date = @temperature.measured_at.to_date

        session.delete(:temperature_measured_at)
        format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("temperatures-date-#{@temperature.measured_at.strftime('%Y%m%d')}", partial: "temperatures/date_section", locals: { date: @temperature.measured_at.to_date, temperatures_by_date: current_child.temperatures.where(measured_at: @temperature.measured_at.all_day).order(measured_at: :desc) }),
            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "体温記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "temperatures/form_modal",
            locals: { temperature: @temperature }
          )
        end
      end
    end
  end

  def edit
    @temperature = current_child.temperatures.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "temperatures/form_modal",
          locals: { temperature: @temperature }
        )
      end
    end
  end

  def update
    @temperature = current_child.temperatures.find(params[:id])

    respond_to do |format|
      if @temperature.update(temperature_params)
         # measured_at を基準に selected_date をセット
         @selected_date = @temperature.measured_at.to_date

        format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を更新しました" }
        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("temperatures-date-#{@temperature.measured_at.strftime('%Y%m%d')}", partial: "temperatures/date_section", locals: { date: @temperature.measured_at.to_date, temperatures_by_date: current_child.temperatures.where(measured_at: @temperature.measured_at.all_day).order(measured_at: :desc) }),
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "体温記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "temperatures/form_modal",
            locals: { temperature: @temperature }
          )
        end
      end
    end
  end

  def destroy
    @temperature = current_child.temperatures.find(params[:id])
    @temperature.destroy
    # measured_at を基準に selected_date をセット
    @selected_date = @temperature.measured_at.to_date

    respond_to do |format|
      format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を削除しました" }
      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("temperatures-date-#{@temperature.measured_at.strftime('%Y%m%d')}", partial: "temperatures/date_section", locals: { date: @temperature.measured_at.to_date, temperatures_by_date: current_child.temperatures.where(measured_at: @temperature.measured_at.all_day).order(measured_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "体温記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def temperature_params
    params.require(:temperature).permit(:measured_at, :temperature, :memo)
  end
end
