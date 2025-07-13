class HomeController < ApplicationController
#　未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  def index
  end
end
