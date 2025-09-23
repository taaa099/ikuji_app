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
        session.delete(:hydration_fed_at)
        format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を保存しました" }
        format.turbo_stream
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
        format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を更新しました" }
        format.turbo_stream
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

    respond_to do |format|
      format.html { redirect_to child_hydrations_path(current_child), notice: "水分補給記録を削除しました" }
      format.turbo_stream
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def hydration_params
    params.require(:hydration).permit(:fed_at, :drink_type, :amount, :memo)
  end
end
