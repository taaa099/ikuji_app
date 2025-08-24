module Notifiable
  extend ActiveSupport::Concern

  included do
    after_create :create_default_notification
  end

  private

  # モデルごとにオーバーライド
  def create_default_notification
    # 空メソッド：各モデルで上書き
  end
end
