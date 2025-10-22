class VaccinationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @vaccinations = current_child.vaccinations

    # 並び順指定
    @vaccinations = case params[:sort]
    when "date_desc"
      @vaccinations.order(vaccinated_at: :desc)
    when "date_asc"
      @vaccinations.order(vaccinated_at: :asc)
    else
      @vaccinations.order(vaccinated_at: :desc)
    end

    # ==== 全日程取得 ====
    if @vaccinations.any?
      vaccination_start_date = @vaccinations.minimum(:vaccinated_at).in_time_zone("Tokyo").to_date
      vaccination_end_date   = [ @vaccinations.maximum(:vaccinated_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @vaccination_all_dates = (vaccination_start_date..vaccination_end_date).to_a.reverse # 新しい日付が上
    else
      @vaccination_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_vaccinations = @vaccinations.group_by { |f| f.vaccinated_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    @vaccination = current_child.vaccinations.new(vaccinated_at: Time.current)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "vaccinations/form_modal",
          locals: { vaccination: @vaccination }
        )
      end
    end
  end

  def create
    @vaccination = current_child.vaccinations.new(vaccinations_params.merge(user: current_user))

    respond_to do |format|
      if @vaccination.save
         # vaccinated_at を基準に selected_date をセット
         @selected_date = @vaccination.vaccinated_at.to_date

        session.delete(:vaccination_vaccinated_at) # セッションから削除
        format.html { redirect_to child_vaccinations_path(current_child), notice: "予防接種記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("vaccinations-date-#{@vaccination.vaccinated_at.strftime('%Y%m%d')}", partial: "vaccinations/date_section", locals: { date: @vaccination.vaccinated_at.to_date, vaccinations_by_date: current_child.vaccinations.where(vaccinated_at: @vaccination.vaccinated_at.all_day).order(vaccinated_at: :desc) }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "予防接種記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "vaccinations/form_modal",
            locals: { vaccination: @vaccination }
          )
        end
      end
    end
  end

  def edit
    @vaccination = current_child.vaccinations.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "vaccinations/form_modal",
          locals: { vaccination: @vaccination }
        )
      end
    end
  end

  def update
    @vaccination = current_child.vaccinations.find(params[:id])
    vaccination_old_date = @vaccination.vaccinated_at.to_date

    respond_to do |format|
      if @vaccination.update(vaccinations_params)
        vaccination_new_date = @vaccination.vaccinated_at.to_date
         # vaccinated_at を基準に selected_date をセット
         @selected_date = @vaccination.vaccinated_at.to_date

        format.html { redirect_to child_vaccinations_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            # === 古い日付セクションを再描画（削除されたレコードを反映） ===
            turbo_stream.replace("vaccinations-date-#{vaccination_old_date.strftime('%Y%m%d')}", partial: "vaccinations/date_section", locals: { date: vaccination_old_date, vaccinations_by_date: current_child.vaccinations.where(vaccinated_at: vaccination_old_date.all_day).order(vaccinated_at: :desc) }),

            # === 新しい日付セクションを再描画（追加されたレコードを反映） ===
            turbo_stream.replace("vaccinations-date-#{vaccination_new_date.strftime('%Y%m%d')}", partial: "vaccinations/date_section", locals: { date: vaccination_new_date, vaccinations_by_date: current_child.vaccinations.where(vaccinated_at: vaccination_new_date.all_day).order(vaccinated_at: :desc) }),


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
            partial: "vaccinations/form_modal",
            locals: { vaccination: @vaccination }
          )
        end
      end
    end
  end

  def destroy
    @vaccination = current_child.vaccinations.find(params[:id])
    @vaccination.destroy
    # vaccinated_at を基準に selected_date をセット
    @selected_date = @vaccination.vaccinated_at.to_date

    respond_to do |format|
      format.html { redirect_to child_vaccinations_path(current_child), notice: "予防接種記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("vaccinations-date-#{@vaccination.vaccinated_at.strftime('%Y%m%d')}", partial: "vaccinations/date_section", locals: { date: @vaccination.vaccinated_at.to_date, vaccinations_by_date: current_child.vaccinations.where(vaccinated_at: @vaccination.vaccinated_at.all_day).order(vaccinated_at: :desc) }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "予防接種記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def vaccinations_params
    params.require(:vaccination).permit(:vaccinated_at, :vaccine_name, :memo)
  end
end
