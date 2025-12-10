require 'rails_helper'

RSpec.describe NotificationSetting, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }

  context "バリデーション" do
    it "ユーザーが紐づいていれば有効である" do
      settings = NotificationSetting.new(user: user)
      expect(settings).to be_valid
    end

    describe "reminder_after" do
      it "1〜12 は有効" do
        (1..12).each do |value|
          settings = NotificationSetting.new(user: user, reminder_after: value)
          expect(settings).to be_valid
        end
      end

      it "0 以下は無効" do
        settings = NotificationSetting.new(user: user, reminder_after: 0)
        expect(settings).not_to be_valid
      end

      it "13 以上は無効" do
        settings = NotificationSetting.new(user: user, reminder_after: 13)
        expect(settings).not_to be_valid
      end

      it "整数以外は無効" do
        settings = NotificationSetting.new(user: user, reminder_after: 1.5)
        expect(settings).not_to be_valid
      end
    end

    describe "alert_after" do
      it "1〜6 は有効" do
        (1..6).each do |value|
          settings = NotificationSetting.new(user: user, alert_after: value)
          expect(settings).to be_valid
        end
      end

      it "0 以下は無効" do
        settings = NotificationSetting.new(user: user, alert_after: 0)
        expect(settings).not_to be_valid
      end

      it "7 以上は無効" do
        settings = NotificationSetting.new(user: user, alert_after: 7)
        expect(settings).not_to be_valid
      end

      it "整数以外は無効" do
        settings = NotificationSetting.new(user: user, alert_after: 2.8)
        expect(settings).not_to be_valid
      end
    end
  end
end
