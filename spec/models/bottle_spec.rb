require 'rails_helper'

RSpec.describe Bottle, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "given_at があり、amount が1以上の数値なら有効である" do
      bottle = Bottle.new(
        user: user,
        child: child,
        given_at: Time.current,
        amount: 120
      )
      expect(bottle).to be_valid
    end

    it "given_at が無いと無効になる" do
      bottle = Bottle.new(
        user: user,
        child: child,
        given_at: nil,
        amount: 120
      )
      expect(bottle).to be_invalid
      expect(bottle.errors[:given_at]).to include("を入力してください")
    end

    it "amount が空だと無効になる" do
      bottle = Bottle.new(
        user: user,
        child: child,
        given_at: Time.current,
        amount: nil
      )
      expect(bottle).to be_invalid
      expect(bottle.errors[:amount]).to include("を入力してください")
    end

    it "amount が数値以外の文字列の場合、変換され 0 として扱われ 1以上エラーになる" do
      bottle = Bottle.new(
        user: user,
        child: child,
        given_at: Time.current,
        amount: "abc"
      )
      expect(bottle).to be_invalid
      expect(bottle.errors[:amount]).to include("は1以上で入力してください")
    end

    it "amount が 1 未満の場合は無効になる" do
      bottle = Bottle.new(
        user: user,
        child: child,
        given_at: Time.current,
        amount: 0
      )
      expect(bottle).to be_invalid
      expect(bottle.errors[:amount]).to include("は1以上で入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      bottle = Bottle.new(
        user: nil,
        child: child,
        given_at: Time.current,
        amount: 100
      )
      expect(bottle).to be_invalid
    end

    it "child が無いと無効になる" do
      bottle = Bottle.new(
        user: user,
        child: nil,
        given_at: Time.current,
        amount: 100
      )
      expect(bottle).to be_invalid
    end
  end
end
