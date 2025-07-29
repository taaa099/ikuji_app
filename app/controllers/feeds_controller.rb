class FeedsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @feeds = current_child.feeds.order(fed_at: :desc) # 時系列順
  end

  def show
  end

  def new
  # インスタンス生成＋現在時刻取得（授乳日時）
   @feed = current_child.feeds.new(fed_at: Time.current)
  end

  def create
    @feed = current_child.feeds.new

  # フォームから送られた分・秒を整数で取り出して合計秒に変換
    left_minutes = params[:left_minutes].to_i
    left_seconds = params[:left_seconds].to_i
    right_minutes = params[:right_minutes].to_i
    right_seconds = params[:right_seconds].to_i

    @feed.left_time = left_minutes * 60 + left_seconds
    @feed.right_time = right_minutes * 60 + right_seconds
    @feed.memo = params[:feed][:memo]
    @feed.fed_at = params[:feed][:fed_at]

    if @feed.save
     session.delete(:feed_fed_at) # セッションから削除
     redirect_to child_feeds_path(current_child), notice: "授乳記録を保存しました"
    else
     flash.now[:alert] = "保存に失敗しました"
     render :new
    end
  end

  def edit
    @feed = current_child.feeds.find(params[:id])
  end

  def update
  end

  def destroy
  end

private
 
  def feed_params
   params.require(:feed).permit(:left_time, :right_time, :memo, :fed_at)
  end
end
