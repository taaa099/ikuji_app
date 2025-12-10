require 'rails_helper'

RSpec.describe Bath, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "bathed_at と bath_type があれば有効である" do
      bath = Bath.new(
        user: user,
        child: child,
        bathed_at: Time.current,
        bath_type: "お風呂"
      )
      expect(bath).to be_valid
    end

    it "bathed_at が無いと無効になる" do
      bath = Bath.new(
        user: user,
        child: child,
        bathed_at: nil,
        bath_type: "お風呂"
      )
      expect(bath).to be_invalid
      expect(bath.errors[:bathed_at]).to include("を入力してください")
    end

    it "bath_type が無いと無効になる" do
      bath = Bath.new(
        user: user,
        child: child,
        bathed_at: Time.current,
        bath_type: nil
      )
      expect(bath).to be_invalid
      expect(bath.errors[:bath_type]).to include("を入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      bath = Bath.new(
        user: nil,
        child: child,
        bathed_at: Time.current,
        bath_type: "お風呂"
      )
      expect(bath).to be_invalid
    end

    it "child が無いと無効になる" do
      bath = Bath.new(
        user: user,
        child: nil,
        bathed_at: Time.current,
        bath_type: "お風呂"
      )
      expect(bath).to be_invalid
    end
  end
end
