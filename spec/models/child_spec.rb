require 'rails_helper'

RSpec.describe Child, type: :model do
  describe "バリデーション" do
    it "name, birth_date, gender があれば有効である" do
      child = Child.new(
        name: "baby",
        birth_date: "2025-1-1",
        gender: "男"
      )
      expect(child).to be_valid
    end

    it "name が無いと無効になる" do
      child = Child.new(
        name: nil,
        birth_date: "2025-1-1",
        gender: "男"
      )
      expect(child).to be_invalid
      expect(child.errors[:name]).to include("を入力してください")
    end

    it "name が30文字を超えると無効になる" do
      child = Child.new(
      name: "あ" * 31,
      birth_date: "2025-1-1",
      gender: "男"
      )
      expect(child).to be_invalid
      expect(child.errors[:name]).to include("は30文字以内で入力してください")
    end

    it "birth_date が無いと無効になる" do
      child = Child.new(
        name: "baby",
        birth_date: nil,
        gender: "男"
      )
      expect(child).to be_invalid
      expect(child.errors[:birth_date]).to include("を入力してください")
    end

    it "gender が無いと無効になる" do
      child = Child.new(
        name: "baby",
        birth_date: "2025-1-1",
        gender: nil
      )
      expect(child).to be_invalid
      expect(child.errors[:gender]).to include("を入力してください")
    end
  end
end
