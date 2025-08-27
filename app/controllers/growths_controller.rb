class GrowthsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

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

  def analysis
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def growth_params
   params.require(:growth).permit(:height, :weight, :head_circumference, :chest_circumference, :recorded_at)
  end
end
