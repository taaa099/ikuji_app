class Growth < ApplicationRecord
  belongs_to :child

  validates :height, :weight, :recorded_at, presence: true
  validates :height, :weight, :head_circumference, :chest_circumference, numericality: { greater_than: 0 }, allow_nil: true
end
