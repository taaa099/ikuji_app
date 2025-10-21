class HydrationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @hydrations = current_child.hydrations

    # 並び順指定
    @hydrations = case params[:sort]
    when "date_desc"
      @hydrations.order(fed_at: :desc)
    when "date_asc"
      @hydrations.order(fed_at: :asc)
    else
      @hydrations.order(fed_at: :desc)
    end

    # ==== 全日程取得 ====
    if @hydrations.any?
      hydration_start_date = @hydrations.minimum(:fed_at).in_time_zone("Tokyo").to_date
      hydration_end_date   = [ @hydrations.maximum(:fed_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @hydration_all_dates = (hydration_start_date..hydration_end_date).to_a.reverse # 新しい日付が上
    else
      @hydration_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_hydrations = @hydrations.group_by { |f| f.fed_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    # インスタンス生成＋現在時刻取得
    @hydration = current_child.hydrations.new(fed_at: Time.current)
  end

  def create
    @hydration = current_child.hydrations.new(hydration_params.merge(user: current_user))

    respond_to do |format|
      if @hydration.save
        # fed_at を基準に selected_date をセット
        @selected_date = @hydration.fed_at.to_date

        session.delete(:hydration_fed_at)
        format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("hydrations-date-#{@hydration.fed_at.strftime('%Y%m%d')}", partial: "hydrations/date_section", locals: { date: @hydration.fed_at.to_date, hydrations_by_date: current_child.hydrations.where(fed_at: @hydration.fed_at.all_day).order(fed_at: :desc) }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "水分補給記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "hydrations/form_modal",
            locals: { hydration: @hydration }
          )
        end
      end
    end
  end

  def edit
    @hydration = current_child.hydrations.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "hydrations/form_modal",
          locals: { hydration: @hydration }
        )
      end
    end
  end

  def update
    @hydration = current_child.hydrations.find(params[:id])

    respond_to do |format|
      if @hydration.update(hydration_params)
        # fed_at を基準に selected_date をセット
        @selected_date = @hydration.fed_at.to_date

        format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("hydrations-date-#{@hydration.fed_at.strftime('%Y%m%d')}", partial: "hydrations/date_section", locals: { date: @hydration.fed_at.to_date, hydrations_by_date: current_child.hydrations.where(fed_at: @hydration.fed_at.all_day).order(fed_at: :desc) }),
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "水分補給記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "hydrations/form_modal",
            locals: { hydration: @hydration }
          )
        end
      end
    end
  end

  def destroy
    @hydration = current_child.hydrations.find(params[:id])
    @hydration.destroy
    # fed_at を基準に selected_date をセット
    @selected_date = @hydration.fed_at.to_date

    respond_to do |format|
      format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("hydrations-date-#{@hydration.fed_at.strftime('%Y%m%d')}", partial: "hydrations/date_section", locals: { date: @hydration.fed_at.to_date, hydrations_by_date: current_child.hydrations.where(fed_at: @hydration.fed_at.all_day).order(fed_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "水分補給記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def hydration_params
    params.require(:hydration).permit(:fed_at, :drink_type, :amount, :memo)
  end
end
