class BottlesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @bottles = current_child.bottles

    # 並び順指定
    @bottles = case params[:sort]
    when "date_desc"
               @bottles.order(given_at: :desc)
    when "date_asc"
               @bottles.order(given_at: :asc)
    else
               @bottles.order(given_at: :desc)
    end
  end

  def show
  end

  def new
    @bottle = current_child.bottles.new(given_at: Time.current)
  end

  def create
    @bottle = current_child.bottles.new(bottle_params.merge(user: current_user))
    if @bottle.save
     session.delete(:bottle_given_at) # セッションから削除
     redirect_to child_bottles_path(current_child), notice: "授乳記録を保存しました"
    else
     flash.now[:alert] = "保存に失敗しました"
     render :new
    end
  end

  def edit
    @bottle = current_child.bottles.find(params[:id])
  end

  def update
    @bottle = current_child.bottles.find(params[:id])
    if @bottle.update(bottle_params)
      redirect_to child_bottles_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @bottle = current_child.bottles.find(params[:id])
    @bottle.destroy
    redirect_to child_bottles_path(current_child), notice: "授乳記録を削除しました"
  end

private

 # フォームから送信されたパラメータのうち、許可するキーを指定
 def bottle_params
  params.require(:bottle).permit(:amount, :given_at, :memo)
 end
end
