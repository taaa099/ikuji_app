class BabyFoodsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @baby_foods = current_child.baby_foods

    # 並び順指定
    @baby_foods = case params[:sort]
    when "date_desc"
      @baby_foods.order(fed_at: :desc)
    when "date_asc"
      @baby_foods.order(fed_at: :asc)
    else
      @baby_foods.order(fed_at: :desc)
    end

    # ==== 全日程取得 ====
    if @baby_foods.any?
      baby_food_start_date = @baby_foods.minimum(:fed_at).in_time_zone("Tokyo").to_date
      baby_food_end_date   = [ @baby_foods.maximum(:fed_at).in_time_zone("Tokyo").to_date, Date.current ].max
      @baby_food_all_dates = (baby_food_start_date..baby_food_end_date).to_a.reverse # 新しい日付が上
    else
      @baby_food_all_dates = [ Date.current ]
    end

    # 日付ごとにグループ化（JST基準）
    @grouped_baby_foods = @baby_foods.group_by { |f| f.fed_at.in_time_zone("Tokyo").to_date }
  end

  def show
  end

  def new
    @baby_food = current_child.baby_foods.new(fed_at: Time.current)
  end

  def create
    @baby_food = current_child.baby_foods.new(baby_food_params.merge(user: current_user))

    respond_to do |format|
      if @baby_food.save
        # fed_at を基準に selected_date をセット
        @selected_date = @baby_food.fed_at.to_date

        session.delete(:baby_food_fed_at) # セッションから削除
        format.html { redirect_to child_baby_foods_path(current_child), notice: "離乳食の記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.replace("baby_foods-container", partial: "baby_foods/index", locals: { baby_foods: current_child.baby_foods.order(fed_at: :desc), grouped_baby_foods: current_child.baby_foods.group_by { |f| f.fed_at.to_date }, baby_food_all_dates: (current_child.baby_foods.any? ? (current_child.baby_foods.minimum(:fed_at).to_date..[ current_child.baby_foods.maximum(:fed_at).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),

            # ダッシュボードの育児記録一覧にも追加
            turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),

            # フラッシュ通知を追加
            turbo_stream.prepend("flash-messages", partial: "shared/flash", locals: { flash: { notice: "離乳食の記録を保存しました" } }),

            # モーダルを閉じる
            turbo_stream.update("modal") { "" }
          ]
        end
      else
        format.html { render :new, status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "baby_foods/form_modal",
            locals: { baby_food: @baby_food }
          )
        end
      end
    end
  end

  def edit
    @baby_food = current_child.baby_foods.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "baby_foods/form_modal",
          locals: { baby_food: @baby_food }
        )
      end
    end
  end

  def update
    @baby_food = current_child.baby_foods.find(params[:id])
    baby_food_old_date = @baby_food.fed_at.to_date

    respond_to do |format|
      if @baby_food.update(baby_food_params)
        baby_food_new_date = @baby_food.fed_at.to_date
        # fed_at を基準に selected_date をセット
        @selected_date = @baby_food.fed_at.to_date

        format.html { redirect_to child_baby_foods_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("baby_foods-container", partial: "baby_foods/index", locals: { baby_foods: current_child.baby_foods.order(fed_at: :desc), grouped_baby_foods: current_child.baby_foods.group_by { |f| f.fed_at.to_date }, baby_food_all_dates: (current_child.baby_foods.any? ? (current_child.baby_foods.minimum(:fed_at).to_date..[ current_child.baby_foods.maximum(:fed_at).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),

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
            partial: "baby_foods/form_modal",
            locals: { baby_food: @baby_food }
          )
        end
      end
    end
  end

  def destroy
    @baby_food = current_child.baby_foods.find(params[:id])
    @baby_food.destroy
    # fed_at を基準に selected_date をセット
    @selected_date = @baby_food.fed_at.to_date

    respond_to do |format|
      format.html { redirect_to child_baby_foods_path(current_child), notice: "記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("baby_foods-container", partial: "baby_foods/index", locals: { baby_foods: current_child.baby_foods.order(fed_at: :desc), grouped_baby_foods: current_child.baby_foods.group_by { |f| f.fed_at.to_date }, baby_food_all_dates: (current_child.baby_foods.any? ? (current_child.baby_foods.minimum(:fed_at).to_date..[ current_child.baby_foods.maximum(:fed_at).to_date, Date.current ].max).to_a.reverse : [ Date.current ]), current_child: current_child }),
          turbo_stream.replace("dashboard-records-container", partial: "home/records_table_or_empty", locals: { records: current_child.records_for_date(@selected_date), selected_date: @selected_date }),
          turbo_stream.prepend(
            "flash-messages",
            partial: "shared/flash",
            locals: { flash: { notice: "記録を削除しました" } }
          ),
          turbo_stream.update("modal") { "" }
        ]
      end
    end
  end

private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def baby_food_params
    params.require(:baby_food).permit(:fed_at, :amount, :memo)
  end
end
