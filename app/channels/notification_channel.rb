class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # 現在ログイン中の子どもIDごとのチャンネルにサブスクライブ
    child = Child.find_by(id: params[:id])
    stream_for child if child
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
