class DiariesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!
  before_action :set_diary, only: [ :show, :edit, :update, :destroy ]

  def index
    @diaries = current_user.diaries.order(date: :desc)
  end

  def show
  end

  def new
    @diary = current_user.diaries.new
  end

  def create
    @diary = current_user.diaries.new(diary_params)
    if @diary.save
      redirect_to diaries_path, notice: "日記を作成しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
    if @diary.update(diary_params)
      redirect_to diaries_path, notice: "日記を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @diary.destroy
    redirect_to diaries_path, notice: "日記を削除しました"
  end

  private

  def set_diary
    @diary = current_user.diaries.find(params[:id])
  end

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def diary_params
    params.require(:diary).permit(:title, :content, :date, images: [], videos: [])
  end
end
