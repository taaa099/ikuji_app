require 'rails_helper'

RSpec.describe Temperature, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "measured_at と temperature が正しければ有効である" do
      temp = Temperature.new(
        user: user,
        child: child,
        measured_at: Time.current,
        temperature: 37.0
      )
      expect(temp).to be_valid
    end

    it "measured_at が無いと無効になる" do
      temp = Temperature.new(
        user: user,
        child: child,
        measured_at: nil,
        temperature: 37.0
      )
      expect(temp).to be_invalid
      expect(temp.errors[:measured_at]).to include("を入力してください")
    end

    it "temperature が無いと無効になる" do
      temp = Temperature.new(
        user: user,
        child: child,
        measured_at: Time.current,
        temperature: nil
      )
      expect(temp).to be_invalid
      expect(temp.errors[:temperature]).to include("を入力してください")
    end

    it "temperature が 35.0 未満だと無効になる" do
      temp = Temperature.new(
        user: user,
        child: child,
        measured_at: Time.current,
        temperature: 34.9
      )
      expect(temp).to be_invalid
      expect(temp.errors[:temperature]).to include("は35.0以上の値にしてください")
    end

    it "temperature が 42.0 を超えると無効になる" do
      temp = Temperature.new(
        user: user,
        child: child,
        measured_at: Time.current,
        temperature: 42.1
      )
      expect(temp).to be_invalid
      expect(temp.errors[:temperature]).to include("は42.0以下の値にしてください")
    end
  end

  describe "関連" do
    it "user が無いと無効になる" do
      temp = Temperature.new(
        user: nil,
        child: child,
        measured_at: Time.current,
        temperature: 37.0
      )
      expect(temp).to be_invalid
      expect(temp.errors[:user]).to include("を入力してください")
    end

    it "child が無いと無効になる" do
      temp = Temperature.new(
        user: user,
        child: nil,
        measured_at: Time.current,
        temperature: 37.0
      )
      expect(temp).to be_invalid
      expect(temp.errors[:child]).to include("を入力してください")
    end
  end
end
