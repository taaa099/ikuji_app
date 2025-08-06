class HydrationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @hydrations = current_child.hydrations.order(fed_at: :desc)
  end

  def show
  end

  def new
    @hydration = current_child.hydrations.new(fed_at: Time.current)
  end

  def create
    @hydration = current_child.hydrations.new(hydration_params)
    if @hydration.save
      session.delete(:hydration_fed_at) # セッションから削除
      redirect_to child_hydrations_path(current_child), notice: "水分補給記録を保存しました"
    else
      flash.now[:alert] = "保存に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

private

 # フォームから送信されたパラメータのうち、許可するキーを指定
 def hydration_params
  params.require(:hydration).permit(:drink_type, :fed_at, :amount, :memo)
 end
end
