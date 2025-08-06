class Hydration < ApplicationRecord
  belongs_to :child

  validates :fed_at, presence: true
  validates :drink_type, presence: true
end
