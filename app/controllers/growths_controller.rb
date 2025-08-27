class GrowthsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @growths = current_child.growths.order(:recorded_at)
  end

  def show
  end

  def new
    @growth = current_child.growths.new(recorded_at: Time.current)
  end

  def create
    @growth = current_child.growths.new(growth_params)
    if @growth.save
      session.delete(:growth_recorded_at) # セッションから削除
      redirect_to child_growths_path(current_child), notice: "成長の記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @growth = current_child.growths.find(params[:id])
  end

  def update
    @growth = current_child.growths.find(params[:id])
    if @growth.update(growth_params)
     redirect_to child_growths_path(current_child), notice: "記録を更新しました"
    else
     flash.now[:alert] = "更新に失敗しました"
     render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @growth = current_child.growths.find(params[:id])
    @growth.destroy
    redirect_to child_growths_path(current_child), notice: "成長記録を削除しました"
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def growth_params
   params.require(:growth).permit(:height, :weight, :head_circumference, :chest_circumference, :recorded_at)
  end
end
