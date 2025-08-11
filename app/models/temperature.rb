class Temperature < ApplicationRecord
  belongs_to :child

  validates :measured_at, presence: true
  validates :temperature, presence: true,
  numericality: { greater_than_or_equal_to: 35.0,
                  less_than_or_equal_to: 42.0 }
end
