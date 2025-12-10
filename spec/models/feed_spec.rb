require 'rails_helper'

RSpec.describe Feed, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "fed_at があれば有効である（left または right が 1秒以上の場合）" do
      feed = Feed.new(
        user: user,
        child: child,
        fed_at: Time.current,
        left_time: 10,
        right_time: 0
      )
      expect(feed).to be_valid
    end

    it "fed_at が無いと無効になる" do
      feed = Feed.new(
        user: user,
        child: child,
        fed_at: nil,
        left_time: 10,
        right_time: 0
      )
      expect(feed).to be_invalid
      expect(feed.errors[:fed_at]).to include("を入力してください")
    end

    it "left_time と right_time が両方 0 または nil の場合は無効になる" do
      feed = Feed.new(
        user: user,
        child: child,
        fed_at: Time.current,
        left_time: 0,
        right_time: 0
      )
      expect(feed).to be_invalid
      expect(feed.errors[:base]).to include("左右どちらかの授乳時間を1秒以上入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      feed = Feed.new(
        user: nil,
        child: child,
        fed_at: Time.current,
        left_time: 10,
        right_time: 0
      )
      expect(feed).to be_invalid
    end

    it "child が無いと無効になる" do
      feed = Feed.new(
        user: user,
        child: nil,
        fed_at: Time.current,
        left_time: 10,
        right_time: 0
      )
      expect(feed).to be_invalid
    end
  end
end
