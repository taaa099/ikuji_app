class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  # Deviseの認証機能
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 中間モデルとの関連
  has_many :user_children, dependent: :destroy

  # 実際に使いたいChildとの関連
  has_many :children, through: :user_children

  # 通知との関連
  has_many :notifications, dependent: :destroy
end
