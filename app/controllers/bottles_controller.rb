class BottlesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @bottles = current_child.bottles.order(given_at: :desc)
  end

  def show
  end

  def new
    @bottle = current_child.bottles.new(given_at: Time.current)
  end

  def create
    @bottle = current_child.bottles.new(bottle_params)

    if @bottle.save
     session.delete(:bottle_given_at) # セッションから削除
     redirect_to child_bottles_path(current_child), notice: "授乳記録を保存しました"
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

 def bottle_params
  params.require(:bottle).permit(:amount, :given_at, :memo)
 end
end
