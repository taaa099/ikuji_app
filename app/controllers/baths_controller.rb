class BathsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baths = current_child.baths

    # 並び順指定
    @baths = case params[:sort]
    when "date_desc"
      @baths.order(bathed_at: :desc)
    when "date_asc"
      @baths.order(bathed_at: :asc)
    else
      @baths.order(bathed_at: :desc)
    end

    # ==== 全日程取得 ====
    if @baths.any?
      bath_start_date = @baths.minimum(:bathed_at).in_time_zone("Tokyo").to_date
      bath_end_date   = [ @baths.maximum(:bathed_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @bath_all_dates = (bath_start_date..bath_end_date).to_a.reverse # 新しい日付が上
    else
      @bath_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_baths = @baths.group_by { |f| f.bathed_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    @bath = current_child.baths.new(bathed_at: Time.current)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "baths/form_modal",
          locals: { bath: @bath }
        )
      end
    end
  end

  def create
    @bath = current_child.baths.new(baths_params.merge(user: current_user))

    respond_to do |format|
      if @bath.save
         # bathed_at を基準に selected_date をセット
         @selected_date = @bath.bathed_at.to_date

         # セッションの一時的な授乳日時を削除
         session.delete(:diaper_bathed_at)

        format.html { redirect_to child_baths_path(current_child), notice: "お風呂記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("baths-date-#{@bath.bathed_at.strftime('%Y%m%d')}", partial: "baths/date_section", locals: { date: @bath.bathed_at.to_date, baths_by_date: current_child.baths.where(bathed_at: @bath.bathed_at.all_day).order(bathed_at: :desc) }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "お風呂記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "baths/form_modal",
            locals: { bath: @bath }
          )
        end
      end
    end
  end

  def edit
    @bath = current_child.baths.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "baths/form_modal",
          locals: { bath: @bath }
        )
      end
    end
  end

  def update
    @bath = current_child.baths.find(params[:id])

    respond_to do |format|
      if @bath.update(baths_params)
         # bathed_at を基準に selected_date をセット
         @selected_date = @bath.bathed_at.to_date

        format.html { redirect_to child_baths_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("baths-date-#{@bath.bathed_at.strftime('%Y%m%d')}", partial: "baths/date_section", locals: { date: @bath.bathed_at.to_date, baths_by_date: current_child.baths.where(bathed_at: @bath.bathed_at.all_day).order(bathed_at: :desc) }),
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "baths/form_modal",
            locals: { bath: @bath }
          )
        end
      end
    end
  end

  def destroy
    @bath = current_child.baths.find(params[:id])
    @bath.destroy
    # bathed_at を基準に selected_date をセット
    @selected_date = @bath.bathed_at.to_date

    respond_to do |format|
      format.html { redirect_to child_baths_path(current_child), notice: "お風呂記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("baths-date-#{@bath.bathed_at.strftime('%Y%m%d')}", partial: "baths/date_section", locals: { date: @bath.bathed_at.to_date, baths_by_date: current_child.baths.where(bathed_at: @bath.bathed_at.all_day).order(bathed_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "お風呂記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def baths_params
    params.require(:bath).permit(:bathed_at, :bath_type, :memo)
  end
end
