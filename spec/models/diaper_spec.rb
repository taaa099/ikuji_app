require 'rails_helper'

RSpec.describe Diaper, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "changed_at があり、pee または poop のいずれかが true なら有効である" do
      diaper = Diaper.new(
        user: user,
        child: child,
        changed_at: Time.current,
        pee: true,
        poop: false
      )
      expect(diaper).to be_valid
    end

    it "changed_at が無いと無効になる" do
      diaper = Diaper.new(
        user: user,
        child: child,
        changed_at: nil,
        pee: true,
        poop: false
      )
      expect(diaper).to be_invalid
      expect(diaper.errors[:changed_at]).to include("を入力してください")
    end

    it "pee と poop が両方 false または nil だと無効になる" do
      diaper = Diaper.new(
        user: user,
        child: child,
        changed_at: Time.current,
        pee: false,
        poop: false
      )
      expect(diaper).to be_invalid
      expect(diaper.errors[:base]).to include("おしっこ、うんちのいずれかを選択してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      diaper = Diaper.new(
        user: nil,
        child: child,
        changed_at: Time.current,
        pee: true,
        poop: false
      )
      expect(diaper).to be_invalid
    end

    it "child が無いと無効になる" do
      diaper = Diaper.new(
        user: user,
        child: nil,
        changed_at: Time.current,
        pee: true,
        poop: false
      )
      expect(diaper).to be_invalid
    end
  end
end
