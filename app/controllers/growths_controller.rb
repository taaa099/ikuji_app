class GrowthsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @growths = current_child.growths.order(:recorded_at)

    @growths_for_chart = @growths.map do |g|
      months = (g.recorded_at.year * 12 + g.recorded_at.month) -
               (current_child.birth_date.year * 12 + current_child.birth_date.month)
      months -= 1 if g.recorded_at.day < current_child.birth_date.day
      { recorded_at: g.recorded_at.strftime("%Y-%m-%d"),
        height: g.height,
        weight: g.weight,
        month_age: months }
    end

    # 一覧用（全件取得・id順）
    growths_for_list = current_child.growths.order(recorded_at: :desc, id: :desc)

    # 日付ごとにグループ化（JST基準）
    @grouped_growths = growths_for_list.group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }

    # 成長記録がある日だけ抽出（降順表示）
    @growth_all_dates = @grouped_growths.keys.sort.reverse
  end

  def new
    @growth = current_child.growths.new(recorded_at: Time.current)
  end

  def create
    @growth = current_child.growths.new(growth_params)
    respond_to do |format|
      if @growth.save
        format.html { redirect_to child_growths_path(current_child), notice: "成長記録を保存しました" }
        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("growths-container", partial: "growths/index", locals: { grouped_growths: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }, growth_all_dates: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),
            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "成長記録を保存しました" } }),
            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "growths/form_modal",
            locals: { growth: @growth }
          )
        end
      end
    end
  end

  def edit
    @growth = current_child.growths.find(params[:id])
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "growths/form_modal",
          locals: { growth: @growth }
        )
      end
    end
  end

  def update
    @growth = current_child.growths.find(params[:id])
    respond_to do |format|
      if @growth.update(growth_params)
        format.html { redirect_to child_growths_path(current_child), notice: "成長記録を更新しました" }
        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("growths-container", partial: "growths/index", locals: { grouped_growths: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }, growth_all_dates: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),
            turbo_stream.prepend(
              "flash-messages",
              partial: "shared/flash",
              locals: { flash: { notice: "成長記録を更新しました" } }
            ),
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "growths/form_modal",
            locals: { growth: @growth }
          )
        end
      end
    end
  end

  def destroy
    @growth = current_child.growths.find(params[:id])
    @growth.destroy
    respond_to do |format|
      format.html { redirect_to child_growths_path(current_child), notice: "成長記録を削除しました" }
      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("growths-container", partial: "growths/index", locals: { grouped_growths: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }, growth_all_dates: current_child.growths.order(recorded_at: :desc, id: :desc).group_by { |g| g.recorded_at.in_time_zone("Tokyo").to_date }.keys.sort.reverse }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "成長記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def growth_params
    params.require(:growth).permit(:height, :weight, :head_circumference, :chest_circumference, :recorded_at)
  end
end
