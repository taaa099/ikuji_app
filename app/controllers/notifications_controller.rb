class NotificationsController < ApplicationController
  def index
    @notifications = current_child.notifications.order(delive_at: :desc)
  end
end
