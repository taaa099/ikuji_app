class NotificationsController < ApplicationController
  # 未ログインユーザーをログイン画面へリダイレクトさせる
  before_action :authenticate_user!

  # 通知一覧
  def index
    @notifications = current_child.notifications.order(delivered_at: :desc)

    # 一覧ページを開いたタイミングで未読を既読にする
    @notifications.where(read: false).update_all(read: true)
  end

  # 個別通知を既読にする
  def mark_as_read
    notification = current_child.notifications.find_by(id: params[:id])
    if notification
      notification.update(read: true)
      head :ok
    else
      head :not_found
    end
  end
end
