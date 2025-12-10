require 'rails_helper'

RSpec.describe Hydration, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "fed_at と drink_type があれば有効である" do
      hydration = Hydration.new(
        user: user,
        child: child,
        fed_at: Time.current,
        drink_type: "お水",
        amount: 100
      )
      expect(hydration).to be_valid
    end

    it "fed_at が無いと無効になる" do
      hydration = Hydration.new(
        user: user,
        child: child,
        fed_at: nil,
        drink_type: "お水",
        amount: 100
      )
      expect(hydration).to be_invalid
      expect(hydration.errors[:fed_at]).to include("を入力してください")
    end

    it "drink_type が無いと無効になる" do
      hydration = Hydration.new(
        user: user,
        child: child,
        fed_at: Time.current,
        drink_type: nil,
        amount: 100
      )
      expect(hydration).to be_invalid
      expect(hydration.errors[:drink_type]).to include("を入力してください")
    end

    it "amount が数値でない場合は無効になる" do
      hydration = Hydration.new(
        user: user,
        child: child,
        fed_at: Time.current,
        drink_type: "お水",
        amount: "abc"
      )
      expect(hydration).to be_invalid
      expect(hydration.errors[:amount]).to include("数値で入力してください")
    end

    it "amount が 0 以下の場合は無効になる" do
      hydration = Hydration.new(
        user: user,
        child: child,
        fed_at: Time.current,
        drink_type: "お水",
        amount: 0
      )
      expect(hydration).to be_invalid
      expect(hydration.errors[:amount]).to include("は1以上で入力してください")
    end

    it "user が無いと無効になる" do
      feed = Hydration.new(
        user: nil,
        child: child,
        fed_at: Time.current,
        drink_type: "お水",
        amount: 100
      )
      expect(feed).to be_invalid
    end

    it "child が無いと無効になる" do
      feed = Hydration.new(
        user: user,
        child: nil,
        fed_at: Time.current,
        drink_type: "お水",
        amount: 100
      )
      expect(feed).to be_invalid
    end
  end
end
