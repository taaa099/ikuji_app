class Diaper < ApplicationRecord
  belongs_to :child

  validate :at_least_one_selected

  private

  # カスタムバリデーションの定義
  def at_least_one_selected
    if pee.nil? && poop.nil?
      errors.add(:base, "おしっこ、うんちのいずれかを選択してください")
    end
  end
end
