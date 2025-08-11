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
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def temperatures_params
    params.require(:temperature).permit(:measured_at, :temperature, :memo)
  end
end
