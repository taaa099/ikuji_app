class ChildrenController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!
  before_action :set_child, only: [ :show, :edit, :update, :destroy, :update_daily_goal ]
  before_action :ensure_child_selected, only: [ :index ]

  def index
    if current_user.children.empty?
      redirect_to new_child_path, notice: "子どもを登録してください"
    else
      @children = current_user.children
    end
  end

  def show
  end

  def new
    @child = Child.new
  end

  def create
    @child = Child.new(child_params)

    if @child.save
      current_user.children << @child unless current_user.children.include?(@child)
      flash[:notice] = "子どもを登録しました"
      redirect_to children_path
    else
      flash.now[:alert] = "登録に失敗しました"
      render :new
    end
  end

  def edit
  end

  def update
    if @child.update(child_params)
      flash[:notice] = "子どもの情報を更新しました"
      redirect_to children_path
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit
    end
  end

  def destroy
    @child.destroy
    flash[:notice] = "子どもを削除しました"
    redirect_to children_path
  end

  # 子供切り替え処理
  def switch
    session[:current_child_id] = params[:id]
    redirect_to children_path, notice: "子どもを切り替えました"
  end

  def switch_page
    @children = current_user.children
  end

  # PATCH /children/:id/update_daily_goal
  def update_daily_goal
    # 更新できるカラムを許可
    permitted = params.require(:child).permit(:daily_bottle_goal, :daily_hydration_goal, :daily_baby_food_goal)

    if @child.update(permitted)
      respond_to do |format|
        format.json { render json: { success: true, child: @child } }
      end
    else
      respond_to do |format|
        format.json { render json: { success: false, errors: @child.errors.full_messages } }
      end
    end
  end

  private

  def set_child
    @child = current_user.children.find(params[:id])
  end

  def child_params
    params.require(:child).permit(:name, :birth_date, :gender, :image)
  end
end
