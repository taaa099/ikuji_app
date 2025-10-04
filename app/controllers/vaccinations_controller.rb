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
        session.delete(:vaccination_vaccinated_at) # セッションから削除
        format.html { redirect_to child_vaccinations_path(current_child), notice: "予防接種記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.prepend("vaccinations-list", partial: "vaccinations/vaccination_row", locals: { vaccination: @vaccination }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.prepend("dashboard-records", partial: "home/record_row", locals: { record: @vaccination }),

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

    respond_to do |format|
      if @vaccination.update(vaccinations_params)
        format.html { redirect_to child_vaccinations_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("vaccination_#{@vaccination.id}", partial: "vaccinations/vaccination_row", locals: { vaccination: @vaccination }),
            turbo_stream.replace("dashboard_record_#{@vaccination.id}", partial: "home/record_row", locals: { record: @vaccination }),
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

    respond_to do |format|
      format.html { redirect_to child_vaccinations_path(current_child), notice: "予防接種記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("vaccination_#{@vaccination.id}"),
          turbo_stream.remove("dashboard_record_#{@vaccination.id}"),
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
