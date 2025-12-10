require 'rails_helper'

RSpec.describe BabyFood, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "fed_at があり、amount が1以上の数値なら有効である" do
      baby_food = BabyFood.new(
        user: user,
        child: child,
        fed_at: Time.current,
        amount: 100
      )
      expect(baby_food).to be_valid
    end

    it "fed_at が無いと無効になる" do
      baby_food = BabyFood.new(
        user: user,
        child: child,
        fed_at: nil,
        amount: 100
      )
      expect(baby_food).to_not be_valid
      expect(baby_food.errors[:fed_at]).to include("を入力してください")
    end

    it "amount が空だと無効になる" do
      baby_food = BabyFood.new(
        user: user,
        child: child,
        fed_at: Time.current,
        amount: nil
      )
      expect(baby_food).to_not be_valid
      expect(baby_food.errors[:amount]).to include("を入力してください")
    end

    it "amount が数値以外の文字列の場合、変換され 0 として扱われ 1以上エラーになる" do
      baby_food = BabyFood.new(
        user: user,
        child: child,
        fed_at: Time.current,
        amount: "abc"
      )
      expect(baby_food).to be_invalid
      expect(baby_food.errors[:amount]).to include("は1以上で入力してください")
    end

    it "amount が 1 未満の場合は無効になる" do
      baby_food = BabyFood.new(
        user: user,
        child: child,
        fed_at: Time.current,
        amount: 0
      )
      expect(baby_food).to be_invalid
      expect(baby_food.errors[:amount]).to include("は1以上で入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      baby_food = BabyFood.new(
        user: nil,
        child: child,
        fed_at: Time.current,
        amount: 100
      )
      expect(baby_food).to be_invalid
    end

    it "child が無いと無効になる" do
      baby_food = BabyFood.new(
        user: user,
        child: nil,
        fed_at: Time.current,
        amount: 100
      )
      expect(baby_food).to be_invalid
    end
  end
end
