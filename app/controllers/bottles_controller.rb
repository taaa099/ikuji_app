class BottlesController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @bottles = current_child.bottles

    # 並び順指定
    @bottles = case params[:sort]
    when "date_desc"
      @bottles.order(given_at: :desc)
    when "date_asc"
      @bottles.order(given_at: :asc)
    else
      @bottles.order(given_at: :desc)
    end

    # ==== 全日程取得 ====
    if @bottles.any?
      bottle_start_date = @bottles.minimum(:given_at).in_time_zone("Tokyo").to_date
      bottle_end_date   = [ @bottles.maximum(:given_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @bottle_all_dates = (bottle_start_date..bottle_end_date).to_a.reverse # 新しい日付が上
    else
      @all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_bottles = @bottles.group_by { |f| f.given_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    # インスタンス生成＋現在時刻取得
    @bottle = current_child.bottles.new(given_at: Time.current)
  end

  def create
    @bottle = current_child.bottles.new(bottle_params.merge(user: current_user))

    respond_to do |format|
      if @bottle.save
        # given_at を基準に selected_date をセット
        @selected_date = @bottle.given_at.to_date

        session.delete(:bottle_given_at)

        format.html { redirect_to child_bottles_path(current_child), notice: "ミルク記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("bottles-date-#{@bottle.given_at.strftime('%Y%m%d')}", partial: "bottles/date_section", locals: { date: @bottle.given_at.to_date, bottles_by_date: current_child.bottles.where(given_at: @bottle.given_at.all_day).order(given_at: :desc) }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "ミルク記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "bottles/form_modal",
            locals: { bottle: @bottle }
          )
        end
      end
    end
  end

  def edit
    @bottle = current_child.bottles.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "bottles/form_modal",
          locals: { bottle: @bottle }
        )
      end
    end
  end

  def update
    @bottle = current_child.bottles.find(params[:id])

    respond_to do |format|
      if @bottle.update(bottle_params)
        # given_at を基準に selected_date をセット
        @selected_date = @bottle.given_at.to_date

        format.html { redirect_to child_bottles_path(current_child), notice: "ミルク記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("bottles-date-#{@bottle.given_at.strftime('%Y%m%d')}", partial: "bottles/date_section", locals: { date: @bottle.given_at.to_date, bottles_by_date: current_child.bottles.where(given_at: @bottle.given_at.all_day).order(given_at: :desc) }),
            turbo_stream.replace("dashboard_record_#{@bottle.id}", partial: "home/record_row", locals: { record: @bottle }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "ミルク記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "bottles/form_modal",
            locals: { bottle: @bottle }
          )
        end
      end
    end
  end

  def destroy
    @bottle = current_child.bottles.find(params[:id])
    @bottle.destroy
    # given_at を基準に selected_date をセット
    @selected_date = @bottle.given_at.to_date

    respond_to do |format|
      format.html { redirect_to child_bottles_path(current_child), notice: "ミルク記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("bottles-date-#{@bottle.given_at.strftime('%Y%m%d')}", partial: "bottles/date_section", locals: { date: @bottle.given_at.to_date, bottles_by_date: current_child.bottles.where(given_at: @bottle.given_at.all_day).order(given_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "ミルク記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def bottle_params
    params.require(:bottle).permit(:amount, :given_at, :memo)
  end
end
