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
        format.html { redirect_to child_baths_path(current_child), notice: "お風呂記録を保存しました" }
        format.turbo_stream
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
        format.html { redirect_to child_baths_path(current_child), notice: "記録を更新しました" }
        format.turbo_stream
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

    respond_to do |format|
      format.html { redirect_to child_baths_path(current_child), notice: "お風呂記録を削除しました" }
      format.turbo_stream
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def baths_params
    params.require(:bath).permit(:bathed_at, :bath_type, :memo)
  end
end
