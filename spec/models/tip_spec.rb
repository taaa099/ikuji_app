require 'rails_helper'

RSpec.describe Tip, type: :model do
  describe "バリデーション" do
    it "title, content, category があれば有効である" do
      tip = Tip.new(
        title: "タイトル",
        content: "内容",
        category: "カテゴリー"
      )
      expect(tip).to be_valid
    end

    it "title が無いと無効になる" do
      tip = Tip.new(
        title: nil,
        content: "内容",
        category: "カテゴリー"
      )
      expect(tip).to be_invalid
      expect(tip.errors[:title]).to include("を入力してください")
    end

    it "content が無いと無効になる" do
      tip = Tip.new(
        title: "タイトル",
        content: nil,
        category: "カテゴリー"
      )
      expect(tip).to be_invalid
      expect(tip.errors[:content]).to include("を入力してください")
    end

    it "category が無いと無効になる" do
      tip = Tip.new(
        title: "タイトル",
        content: "内容",
        category: nil
      )
      expect(tip).to be_invalid
      expect(tip.errors[:category]).to include("を入力してください")
    end
  end
end
