class Child < ApplicationRecord
  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy

  # 実際に使いたいChildとの関連
  has_many :users, through: :user_children

  # 子どものプロフィール画像を1枚だけ添付できるようにするActiveStorageの設定
  has_one_attached :image

  # 子どもの名前と誕生日は必須項目(名前は30文字まで)
  validates :name, presence: true, length: { maximum: 30 }
  validates :birth_date, presence: true
end
