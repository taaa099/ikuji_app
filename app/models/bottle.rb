class Bottle < ApplicationRecord
  include Notifiable
  belongs_to :user
  belongs_to :child

  validate :validate_amount
  validates :given_at, presence: true

  private

  def validate_amount
    if amount.blank?
     errors.add(:amount, "を入力してください")
    elsif !amount.is_a?(Numeric)
     errors.add(:amount, "は数値で入力してください")
    elsif amount < 1
     errors.add(:amount, "は1以上で入力してください")
    end
  end
end
