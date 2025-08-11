class Vaccination < ApplicationRecord
  belongs_to :child

  validates :vaccinated_at, presence: true
  validates :vaccine_name, presence: true
end
