require 'rails_helper'

RSpec.describe Diary, type: :model do
  let(:user) { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }

  describe "バリデーション" do
    it "date, title, content があれば有効である" do
      diary = Diary.new(
        user: user,
        date: Date.today,
        title: "今日の出来事",
        content: "散歩に行きました。"
      )
      expect(diary).to be_valid
    end

    it "title が無いと無効になる" do
      diary = Diary.new(
        user: user,
        date: Date.today,
        title: nil,
        content: "内容"
      )
      expect(diary).to be_invalid
      expect(diary.errors[:title]).to include("を入力してください")
    end

    it "content が無いと無効になる" do
      diary = Diary.new(
        user: user,
        date: Date.today,
        title: "タイトル",
        content: nil
      )
      expect(diary).to be_invalid
      expect(diary.errors[:content]).to include("を入力してください")
    end

    it "date が無いと無効になる" do
      diary = Diary.new(
        user: user,
        date: nil,
        title: "タイトル",
        content: "内容"
      )
      expect(diary).to be_invalid
      expect(diary.errors[:date]).to include("を入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      diary = Diary.new(
        user: nil,
        date: Date.today,
        title: "タイトル",
        content: "内容"
      )
      expect(diary).to be_invalid
      expect(diary.errors[:user]).to include("を入力してください")
    end
  end
end
