require 'rails_helper'

RSpec.describe SleepRecord, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "start_time と end_time が正しければ有効である" do
      sleep_record = SleepRecord.new(
        user: user,
        child: child,
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
      expect(sleep_record).to be_valid
    end

    it "start_time と end_time が両方空の場合は無効になる" do
      sleep_record = SleepRecord.new(
        user: user,
        child: child,
        start_time: nil,
        end_time: nil
      )
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:start_time]).to include("を入力してください")
    end

    it "start_time が空で end_time のみある場合は無効になる" do
      sleep_record = SleepRecord.new(
        user: user,
        child: child,
        start_time: nil,
        end_time: Time.current
      )
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:start_time]).to include("は必須です。終了時間だけの入力はできません。")
    end

    it "end_time が開始時間より前の場合は無効になる" do
      sleep_record = SleepRecord.new(
        user: user,
        child: child,
        start_time: Time.current,
        end_time: Time.current - 1.hour
      )
      expect(sleep_record).to_not be_valid
      expect(sleep_record.errors[:end_time]).to include("は開始時間より後でなければなりません。")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      sleep_record = SleepRecord.new(
        user: nil,
        child: child,
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
      expect(sleep_record).to be_invalid
    end

    it "child が無いと無効になる" do
      sleep_record = SleepRecord.new(
        user: user,
        child: nil,
        start_time: Time.current,
        end_time: Time.current + 1.hour
      )
      expect(sleep_record).to be_invalid
    end
  end
end
