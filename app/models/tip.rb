class Tip < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :category, presence: true

  has_many_attached :images
end
