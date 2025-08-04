class Diaper < ApplicationRecord
  belongs_to :child

  validate :at_least_one_selected
  validates :changed_at, presence: true

  private

  def at_least_one_selected
    unless pee || poop
     errors.add(:base, "おしっこ、うんちのいずれかを選択してください")
    end
  end
end
