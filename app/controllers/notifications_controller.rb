class NotificationsController < ApplicationController

  def index
    @notifications = current_child.notifications.order(delivered_at: :desc)

    # 一覧ページを開いたタイミングで既読にする
    @notifications.where(read: false).update_all(read: true)
  end

  # 最新の通知を返す
  def latest
    child = current_user.children.find_by(id: params[:child_id])
    unless child
      render json: {}
      return
    end

    notification = child.notifications.unread.order(created_at: :desc).first
    if notification
      render json: { id: notification.id, title: notification.title, message: notification.message }
    else
      render json: {}
    end
  end

  def mark_as_read
    child = current_user.children.find_by(id: params[:child_id])
    unless child
      head :not_found
      return
    end

    notification = child.notifications.find_by(id: params[:id])
    if notification
      notification.update(read: true)
      head :ok
    else
      head :not_found
    end
  end
end
