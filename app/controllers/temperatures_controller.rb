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
        session.delete(:temperature_measured_at)
        format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を保存しました" }
        format.turbo_stream
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
        format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を更新しました" }
        format.turbo_stream
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

    respond_to do |format|
      format.html { redirect_to child_temperatures_path(current_child), notice: "体温記録を削除しました" }
      format.turbo_stream
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def temperature_params
    params.require(:temperature).permit(:measured_at, :temperature, :memo)
  end
end
