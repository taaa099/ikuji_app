class BabyFoodsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baby_foods = current_child.baby_foods.order(fed_at: :desc)
  end

  def show
  end

  def new
    @baby_food = current_child.baby_foods.new(fed_at: Time.current)
  end

  def create
    @baby_food = current_child.baby_foods.new(baby_food_params)
    if @baby_food.save
      session.delete(:baby_food_fed_at) # セッションから削除
      redirect_to child_baby_foods_path(current_child), notice: " 離乳食の記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
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
