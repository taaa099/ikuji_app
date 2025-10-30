class NotificationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  # 通知一覧
  def index
    @notifications = current_child.notifications.order(delivered_at: :desc)
  end

  # 未読をまとめて既読にする
  def mark_all_as_read
    current_child.notifications.where(read: false).update_all(read: true)
    head :ok
  end
end
