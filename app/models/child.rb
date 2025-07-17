class Child < ApplicationRecord
  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy

  # 実際に使いたいChildとの関連
  has_many :users, through: :UserChild
end
