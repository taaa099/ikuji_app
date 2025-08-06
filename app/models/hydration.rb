class Hydration < ApplicationRecord
  belongs_to :child

  validates :fed_at, presence: true
  validates :drink_type, presence: true
  validates :amount, numericality: { greater_than: 0 }, allow_nil: true
end
