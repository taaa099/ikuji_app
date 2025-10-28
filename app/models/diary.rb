class Diary < ApplicationRecord
  belongs_to :user

  # ActiveStorage
  has_many_attached :media

  # バリデーション
  validates :title, presence: true
  validates :content, presence: true
  validates :date, presence: true
end
