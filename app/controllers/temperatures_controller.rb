class TemperaturesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @temperatures = current_child.temperatures.order(measured_at: :desc)
  end

  def show
  end

  def new
    @temperature = current_child.temperatures.new(measured_at: Time.current)
  end

  def create
    @temperature = current_child.temperatures.new(temperatures_params.merge(user: current_user))
    if @temperature.save
      session.delete(:temperature_measured_at) # セッションから削除
      redirect_to child_temperatures_path(current_child), notice: "体温の記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @temperature = current_child.temperatures.find(params[:id])
  end

  def update
    @temperature = current_child.temperatures.find(params[:id])
    if @temperature.update(temperatures_params)
      redirect_to child_temperatures_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @temperature = current_child.temperatures.find(params[:id])
     @temperature.destroy
    redirect_to child_temperatures_path(current_child), notice: "記録を削除しました"
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def temperatures_params
    params.require(:temperature).permit(:measured_at, :temperature, :memo)
  end
end
