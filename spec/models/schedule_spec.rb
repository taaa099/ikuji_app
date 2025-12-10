require 'rails_helper'

RSpec.describe Schedule, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "title, user_only, start_time, end_time があれば有効である" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: true,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_valid
    end

    it "start_time が無いと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: true,
        start_time: nil,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:start_time]).to include("を入力してください")
    end

    it "end_time が無いと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: true,
        start_time: Time.current,
        end_time: nil,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:end_time]).to include("を入力してください")
    end

    it "end_time が start_time より前だと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: true,
        start_time: Time.current,
        end_time: Time.current - 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:end_time]).to include("は開始時刻以降にしてください")
    end

    it "user_only が false の場合、child_ids がないと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: false,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:child_ids]).to include("を少なくとも1つ選択してください")
    end

    it "user_only が false でも child_ids があれば有効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: false,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false,
        child_ids: [ child.id ]
      )
      expect(schedule).to be_valid
    end

    it "title が無いと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: nil,
        user_only: true,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:title]).to include("を入力してください")
    end

    it "title が50文字を超えると無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "あ" * 51,
        user_only: true,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:title]).to include("は50文字以内で入力してください")
    end

    it "all_day が true/false 以外だと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: true,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: nil
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:all_day]).to include("は一覧にありません")
    end

    it "user_only が true/false 以外だと無効になる" do
      schedule = Schedule.new(
        user: user,
        title: "予定",
        user_only: nil,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
      expect(schedule.errors[:user_only]).to include("は一覧にありません")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      schedule = Schedule.new(
        user: nil,
        title: "予定",
        user_only: true,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false
      )
      expect(schedule).to be_invalid
    end

    it "children を複数持てる（through schedule_children）" do
      schedule = Schedule.create!(
        user: user,
        title: "予定",
        user_only: false,
        start_time: Time.current,
        end_time: Time.current + 1.hour,
        all_day: false,
        child_ids: [ child.id ]
      )
      expect(schedule.children.count).to eq(1)
    end
  end
end
