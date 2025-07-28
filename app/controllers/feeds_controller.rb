class FeedsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @child = Child.find(params[:child_id])
    @feeds = @child.feeds.order(fed_at: :desc) # 時系列順
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
    @child = Child.find(params[:child_id])
    @feed = @child.feeds.find(params[:id])
  end

  def update
  end

  def destroy
  end
end
