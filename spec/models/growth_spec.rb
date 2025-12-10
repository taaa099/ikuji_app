require 'rails_helper'

RSpec.describe Growth, type: :model do
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "recorded_at, height, weight があれば有効である" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 60.5,
        weight: 6.5,
        head_circumference: 40.0,
        chest_circumference: 38.5
      )
      expect(growth).to be_valid
    end

    it "height が無いと無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: nil,
        weight: 6.5
      )
      expect(growth).to be_invalid
      expect(growth.errors[:height]).to include("を入力してください")
    end

    it "weight が無いと無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 60.0,
        weight: nil
      )
      expect(growth).to be_invalid
      expect(growth.errors[:weight]).to include("を入力してください")
    end

    it "recorded_at が無いと無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: nil,
        height: 60.0,
        weight: 6.5
      )
      expect(growth).to be_invalid
      expect(growth.errors[:recorded_at]).to include("を入力してください")
    end

    it "height が 0 以下なら無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 0,
        weight: 6.5
      )
      expect(growth).to be_invalid
      expect(growth.errors[:height]).to include("は1以上で入力してください")
    end

    it "weight が 0 以下なら無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 60.0,
        weight: 0
      )
      expect(growth).to be_invalid
      expect(growth.errors[:weight]).to include("は1以上で入力してください")
    end

    it "head_circumference が 0 以下なら無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 60.0,
        weight: 6.5,
        head_circumference: 0
      )
      expect(growth).to be_invalid
      expect(growth.errors[:head_circumference]).to include("は1以上で入力してください")
    end

    it "chest_circumference が 0 以下なら無効になる" do
      growth = Growth.new(
        child: child,
        recorded_at: Time.current,
        height: 60.0,
        weight: 6.5,
        chest_circumference: 0
      )
      expect(growth).to be_invalid
      expect(growth.errors[:chest_circumference]).to include("は1以上で入力してください")
    end
  end

  describe "関連付け" do
    it "child が無いと無効になる" do
      growth = Growth.new(
        child: nil,
        recorded_at: Time.current,
        height: 60.0,
        weight: 6.5,
      )
      expect(growth).to be_invalid
    end
  end
end
