class TipsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @tips = Tip.order(created_at: :desc)
  end

  def show
    @tip = Tip.find(params[:id])
  end
end