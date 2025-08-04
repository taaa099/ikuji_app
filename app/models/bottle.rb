class Bottle < ApplicationRecord
  belongs_to :child

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :given_at, presence: true
end
