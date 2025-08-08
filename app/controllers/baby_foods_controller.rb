class BabyFoodsController < ApplicationController
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
  def baby_food_params
    params.require(:baby_food).permit(:fed_at, :amount, :memo)
  end
end
