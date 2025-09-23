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
  end

  def create
    @vaccination = current_child.vaccinations.new(vaccinations_params.merge(user: current_user))
    if @vaccination.save
      session.delete(:vaccination_vaccinated_at) # セッションから削除
      redirect_to child_vaccinations_path(current_child), notice: "お風呂記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
    @vaccination = current_child.vaccinations.find(params[:id])
  end

  def update
    @vaccination = current_child.vaccinations.find(params[:id])
    if @vaccination.update(vaccinations_params)
      redirect_to child_vaccinations_path(current_child), notice: "記録を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vaccination = current_child.vaccinations.find(params[:id])
    if @vaccination.destroy
      redirect_to child_vaccinations_path(current_child), notice: "予防接種記録を削除しました"
    end
  end

  private

  # フォームから送信されたパラメータのうち、許可するキーを指定
  def vaccinations_params
    params.require(:vaccination).permit(:vaccinated_at, :vaccine_name, :memo)
  end
end
