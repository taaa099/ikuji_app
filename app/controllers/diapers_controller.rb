class DiapersController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @diapers = current_child.diapers

    # 並び順
    @diapers = case params[:sort]
    when "date_desc"
      @diapers.order(changed_at: :desc)
    when "date_asc"
      @diapers.order(changed_at: :asc)
    else
      @diapers.order(changed_at: :desc)
    end
  end

  def show
  end

  def new
    @diaper = current_child.diapers.new(changed_at: Time.current)
  end

  def create
    @diaper = current_child.diapers.new(diaper_params.merge(user: current_user))

    respond_to do |format|
      if @diaper.save
        session.delete(:diaper_changed_at)
        format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を保存しました" }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diapers/form_modal",
            locals: { diaper: @diaper }
          )
        end
      end
    end
  end

  def edit
    @diaper = current_child.diapers.find(params[:id])

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "modal",
          partial: "diapers/form_modal",
          locals: { diaper: @diaper }
        )
      end
    end
  end

  def update
    @diaper = current_child.diapers.find(params[:id])
    @diaper.assign_attributes(diaper_params)

    respond_to do |format|
      if @diaper.save
        format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を更新しました" }
        format.turbo_stream
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "modal",
            partial: "diapers/form_modal",
            locals: { diaper: @diaper }
          )
        end
      end
    end
  end

  def destroy
    @diaper = current_child.diapers.find(params[:id])
    @diaper.destroy

    respond_to do |format|
      format.html { redirect_to child_diapers_path(current_child), notice: "おむつ記録を削除しました" }
      format.turbo_stream
    end
  end

  private

  # 許可されたパラメータに変換済みのpee/poopを追加
  def diaper_params
    params.require(:diaper).permit(:changed_at, :memo).merge(
      pee: to_boolean(params[:diaper][:pee]),
      poop: to_boolean(params[:diaper][:poop])
    )
  end

  # 文字列をbooleanに変換
  def to_boolean(value)
    ActiveModel::Type::Boolean.new.cast(value)
  end
end
