class BabyFoodsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baby_foods = current_child.baby_foods

    # 並び順指定
    @baby_foods = case params[:sort]
    when "date_desc"
               @baby_foods.order(fed_at: :desc)
    when "date_asc"
               @baby_foods.order(fed_at: :asc)
    else
               @baby_foods.order(fed_at: :desc)
    end
  end

  def show
  end

  def new
    @baby_food = current_child.baby_foods.new(fed_at: Time.current)
  end

  def create
    @baby_food = current_child.baby_foods.new(baby_food_params.merge(user: current_user))
    if @baby_food.save
      session.delete(:baby_food_fed_at) # セッションから削除
      redirect_to child_baby_foods_path(current_child), notice: " 離乳食の記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @baby_food = current_child.baby_foods.find(params[:id])
  end

  def update
    @baby_food = current_child.baby_foods.find(params[:id])
    if @baby_food.update(baby_food_params)
      redirect_to child_baby_foods_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @baby_food = current_child.baby_foods.find(params[:id])
    @baby_food.destroy
    redirect_to child_baby_foods_path(current_child), notice: "記録を削除しました"
  end

private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def baby_food_params
    params.require(:baby_food).permit(:fed_at, :amount, :memo)
  end
end
