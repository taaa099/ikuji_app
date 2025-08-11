class BathsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baths = current_child.baths.order(bathed_at: :desc)
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
  def baths_params
    params.require(:bath).permit(:bathed_at, :bath_type, :memo)
  end
end
