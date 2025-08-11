class Bath < ApplicationRecord
  belongs_to :child

  validates :bathed_at, presence: true
  validates :bath_type, presence: true
end
