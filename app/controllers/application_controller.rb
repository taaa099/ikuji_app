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

  protected

  # authenticate_user! のリダイレクト先を/topにオーバーライド
  def authenticate_user!(opts = {})
    unless user_signed_in?
      redirect_to top_path
    end
  end

  private

  # 全ビューで @current_child を使えるようにセットする
  def set_current_child_for_view
    @current_child = current_child
  end

  def ensure_child_selected
    # ユーザーがサインインしている & current_child が未選択の場合
    if user_signed_in? && current_child.nil?
      unless request.path == switch_page_children_path
        redirect_to switch_page_children_path
      end
    end
  end
end
