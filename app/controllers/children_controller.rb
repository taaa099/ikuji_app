class ChildrenController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    if current_user.children.empty?
    redirect_to new_child_path, notice: "子どもを登録してください"
    else
    @children = current_user.children
    end
  end

  def show
    @child = current_user.children.find(params[:id])
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
    @child = current_user.children.find(params[:id])
  end

  def update
    @child = current_user.children.find(params[:id])
  if @child.update(child_params)
    flash[:notice] = "子どもの情報を更新しました"
    redirect_to children_path
  else
    flash.now[:alert] = "更新に失敗しました"
    render :edit
  end
  end

  def destroy
    @child = current_user.children.find(params[:id])
    @child.destroy
    flash[:notice] = "子どもを削除しました"
    redirect_to children_path
  end

  private

  def child_params
    params.require(:child).permit(:name, :birth_date, :gender, :image)
  end
end
