class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_current_child_for_view

  # 子供切り替え
  def current_child
    return nil unless current_user
    @current_child ||= current_user.children.find_by(id: session[:current_child_id])
  end
  helper_method :current_child

  private

  # 全ビューで @current_child を使えるようにセットする
  def set_current_child_for_view
    @current_child = current_child
  end
end
