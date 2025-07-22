class Child < ApplicationRecord
  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy

  # 実際に使いたいChildとの関連
  has_many :users, through: :user_children

  # 子どものプロフィール画像を1枚だけ添付できるようにするActiveStorageの設定
  has_one_attached :image
end
