class FeedsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    if current_child
      @feeds = current_child.feeds.order(fed_at: :desc)
    else
      @feeds = Feed.none  # 空の ActiveRecord::Relation を返す
      flash[:alert] = "表示する子供が選択されていません。"
      redirect_to root_path and return
    end
  end

  def show
  end

  def new
   # インスタンス生成＋現在時刻取得（授乳日時）
   @feed = current_child.feeds.new(fed_at: Time.current)
  end

  def create
    @feed = current_child.feeds.new(feed_params.merge(user: current_user))
    # フォームから送られた分・秒を整数で取り出して合計秒に変換
    left_minutes = params[:left_minutes].to_i
    left_seconds = params[:left_seconds].to_i
    right_minutes = params[:right_minutes].to_i
    right_seconds = params[:right_seconds].to_i

    @feed.left_time = left_minutes * 60 + left_seconds
    @feed.right_time = right_minutes * 60 + right_seconds

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

    @left_minutes = @feed.left_time.to_i / 60
    @left_seconds = @feed.left_time.to_i % 60
    @right_minutes = @feed.right_time.to_i / 60
    @right_seconds = @feed.right_time.to_i % 60
  end

  def update
    @feed = current_child.feeds.find(params[:id])

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
     redirect_to child_feeds_path(current_child), notice: "授乳記録を更新しました"
    else
     # エラー時に再表示用の値を渡す
     @left_minutes = left_minutes
     @left_seconds = left_seconds
     @right_minutes = right_minutes
     @right_seconds = right_seconds
     flash.now[:alert] = "更新に失敗しました"
     render :edit
    end
  end

  def destroy
    @feed = current_child.feeds.find(params[:id])
    @feed.destroy
    redirect_to child_feeds_path(current_child), notice: "授乳記録を削除しました"
  end

private
  # フォームから送信されたパラメータのうち、許可するキーを指定
  def feed_params
   params.require(:feed).permit(:left_time, :right_time, :memo, :fed_at)
  end
end
