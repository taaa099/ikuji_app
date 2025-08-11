class BathsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baths = current_child.baths.order(bathed_at: :desc)
  end

  def show
  end

  def new
    @bath = current_child.baths.new(bathed_at: Time.current)
  end

  def create
    @bath = current_child.baths.new(baths_params)
    if @bath.save
      session.delete(:bath_bathed_at) # セッションから削除
      redirect_to child_baths_path(current_child), notice: "お風呂記録を保存しました"
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
  def baths_params
    params.require(:bath).permit(:bathed_at, :bath_type, :memo)
  end
end
