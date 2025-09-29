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
        session.delete(:baby_food_fed_at) # セッションから削除
        format.html { redirect_to child_baby_foods_path(current_child), notice: "離乳食の記録を保存しました" }

        format.turbo_stream do
          render turbo_stream: [
            # 作成したレコードをリストに追加
            turbo_stream.prepend("baby_foods-list", partial: "baby_foods/baby_food_row", locals: { baby_food: @baby_food }),

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

    respond_to do |format|
      if @baby_food.update(baby_food_params)
        format.html { redirect_to child_baby_foods_path(current_child), notice: "記録を更新しました" }

        # Turbo Streamで一覧置換＋フラッシュ追加＋モーダル閉じる
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("baby_food_#{@baby_food.id}", partial: "baby_foods/baby_food_row", locals: { baby_food: @baby_food }),
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

    respond_to do |format|
      format.html { redirect_to child_baby_foods_path(current_child), notice: "記録を削除しました" }

      # Turbo Streamで一覧削除＋フラッシュ追加＋モーダル閉じる
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("baby_food_#{@baby_food.id}"),
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
