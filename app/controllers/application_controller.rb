class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # 子供切り替え
def current_child
  @current_child ||= current_user.children.find_by(id: session[:current_child_id])
end
helper_method :current_child
end
