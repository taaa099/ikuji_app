class SchedulesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
  end

  def show
  end

  def new
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
 def schedule_params
  params.require(:schedule).permit(:start_time, :end_time, :title, :all_day, :repeat, :memo)
 end
end
