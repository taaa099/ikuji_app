class UsersController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def setting
  end
end
