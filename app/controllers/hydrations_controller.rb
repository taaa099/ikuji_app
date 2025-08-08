class HydrationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @hydrations = current_child.hydrations.order(fed_at: :desc)
  end

  def show
  end

  def new
    @hydration = current_child.hydrations.new(fed_at: Time.current)
  end

  def create
    @hydration = current_child.hydrations.new(hydration_params)
    if @hydration.save
      session.delete(:hydration_fed_at) # セッションから削除
      redirect_to child_hydrations_path(current_child), notice: "水分補給記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @hydration = current_child.hydrations.find(params[:id])
  end

  def update
    @hydration = current_child.hydrations.find(params[:id])
    if @hydration.update(hydration_params)
      redirect_to child_hydrations_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @hydration = current_child.hydrations.find(params[:id])
    @hydration.destroy
    redirect_to child_hydrations_path(current_child), notice: "水分補給記録を削除しました"
  end

private

 # フォームから送信されたパラメータのうち、許可するキーを指定
 def hydration_params
  params.require(:hydration).permit(:drink_type, :fed_at, :amount, :memo)
 end
end
