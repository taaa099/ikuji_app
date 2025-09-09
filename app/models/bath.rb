class Bath < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validates :bathed_at, presence: true
  validates :bath_type, presence: true
end
