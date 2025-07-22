class ChildrenController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
    @children = current_user.children
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
  end

  def destroy
  end

  private

  def child_params
    params.require(:child).permit(:name, :birth_date, :gender, :image)
  end
end

