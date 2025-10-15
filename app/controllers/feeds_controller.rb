class FeedsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @feeds = current_child.feeds

    # 並び順指定
    @feeds = case params[:sort]
    when "date_desc"
               @feeds.order(fed_at: :desc)
    when "date_asc"
               @feeds.order(fed_at: :asc)
    else
               @feeds.order(fed_at: :desc)
    end
  end

  def show
  end

  def new
    # インスタンス生成＋現在時刻取得（授乳日時）
    @feed = current_child.feeds.new(fed_at: Time.current)
  end

  def create
    # 現在の子どもに紐づく授乳記録インスタンスを生成＋フォームパラメータ結合
    @feed = current_child.feeds.new(feed_params.merge(user: current_user))

    # 左右の授乳時間を秒数に変換してセット
    @feed.left_time  = params[:left_minutes].to_i * 60 + params[:left_seconds].to_i
    @feed.right_time = params[:right_minutes].to_i * 60 + params[:right_seconds].to_i

    respond_to do |format|
      if @feed.save
        # fed_at を基準に selected_date をセット
        @selected_date = @feed.fed_at.to_date

        # セッションの一時的な授乳日時を削除
        session.delete(:feed_fed_at)

        # HTML形式の場合のリダイレクト
        format.html { redirect_to child_feeds_path(current_child), notice: "授乳記録を保存しました" }

        # Turbo Stream形式の場合の非同期更新
        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードを育児記録一覧に先頭追加
            turbo_stream.prepend("feeds-list", partial: "feeds/feed_row", locals: { feed: @feed }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "授乳記録を保存しました" } }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        # 保存に失敗した場合のHTML表示
        format.html { render :new, status: :unprocessable_entity }

        # 保存に失敗した場合のTurbo Streamでモーダルを再表示
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "feeds/form_modal",
            locals: {
              feed: @feed,
              left_minutes: params[:left_minutes],
              left_seconds: params[:left_seconds],
              right_minutes: params[:right_minutes],
              right_seconds: params[:right_seconds]
            }
          )
        end
      end
    end
  end

  def edit
    @feed = current_child.feeds.find(params[:id])
    @left_minutes  = @feed.left_time.to_i / 60
    @left_seconds  = @feed.left_time.to_i % 60
    @right_minutes = @feed.right_time.to_i / 60
    @right_seconds = @feed.right_time.to_i % 60

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "feeds/form_modal",
          locals: { feed: @feed }
        )
      end
    end
  end

  def update
    @feed = current_child.feeds.find(params[:id])
    # 左右の授乳時間を秒数に変換してセット
    @feed.left_time  = params[:left_minutes].to_i * 60 + params[:left_seconds].to_i
    @feed.right_time = params[:right_minutes].to_i * 60 + params[:right_seconds].to_i
    @feed.memo       = params[:feed][:memo]
    @feed.fed_at     = params[:feed][:fed_at]

    respond_to do |format|
      if @feed.save
        # fed_at を基準に selected_date をセット
        @selected_date = @feed.fed_at.to_date

        # HTML形式の場合のリダイレクト
        format.html { redirect_to child_feeds_path(current_child), notice: "授乳記録を更新しました" }

        # Turbo Stream形式で一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("feed_#{@feed.id}", partial: "feeds/feed_row", locals: { feed: @feed }),
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "授乳記録を更新しました" } }),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        # 更新失敗時のHTML表示
        format.html { render :edit, status: :unprocessable_entity }

        # 更新失敗時のTurbo Streamでモーダル再表示
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "feeds/form_modal",
            locals: {
              feed: @feed,
              left_minutes: params[:left_minutes],
              left_seconds: params[:left_seconds],
              right_minutes: params[:right_minutes],
              right_seconds: params[:right_seconds]
            }
          )
        end
      end
    end
  end

  def destroy
    @feed = current_child.feeds.find(params[:id])
    @feed.destroy
    # fed_at を基準に selected_date をセット
    @selected_date = @feed.fed_at.to_date

    respond_to do |format|
      # HTML形式の場合のリダイレクト
      format.html { redirect_to child_feeds_path(current_child), notice: "授乳記録を削除しました" }

      # Turbo Stream形式で一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("feed_#{@feed.id}"),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "授乳記録を削除しました" } }),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

private
  # フォームから送信されたパラメータのうち、許可するキーを指定
  def feed_params
    params.require(:feed).permit(:left_time, :right_time, :memo, :fed_at)
  end
end
