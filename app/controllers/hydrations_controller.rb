class HydrationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
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
 def hydration_params
  params.require(:hydration).permit(:drink_type, :fed_at, :memo)
 end
end
