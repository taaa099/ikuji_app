class DiapersController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @diapers = current_child.diapers.order(changed_at: :desc)
  end

  def show
  end

  def new
    @diaper = current_child.diapers.new(changed_at: Time.current)
  end

  def create
    @diaper = current_child.diapers.new(diaper_params.merge(user: current_user))

    if @diaper.save
     session.delete(:diaper_changed_at) # セッションから削除
     redirect_to child_diapers_path(current_child), notice: "授乳記録を保存しました"
    else
     flash.now[:alert] = "保存に失敗しました"
     render :new
    end
  end

  def edit
    @diaper = current_child.diapers.find(params[:id])
  end

  def update
    @diaper = current_child.diapers.find(params[:id])
    if @diaper.update(diaper_params)
     redirect_to child_diapers_path(current_child), notice: "記録を更新しました"
    else
     flash.now[:alert] = "更新に失敗しました"
     render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @diaper = current_child.diapers.find(params[:id])
    @diaper.destroy
    redirect_to child_diapers_path(current_child), notice: "授乳記録を削除しました"
  end

  private

  # 許可されたパラメータに変換済みのpee/poopを追加
  def diaper_params
    params.require(:diaper).permit(:changed_at, :memo).merge(
      pee: to_boolean(params[:diaper][:pee]),
      poop: to_boolean(params[:diaper][:poop])
    )
  end

  # 文字列をbooleanに変換
  def to_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
