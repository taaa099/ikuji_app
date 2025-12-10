require 'rails_helper'

RSpec.describe Vaccination, type: :model do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-1-1", gender: "男") }

  describe "バリデーション" do
    it "vaccinated_at と vaccine_name があれば有効である" do
      vaccination = Vaccination.new(
        user: user,
        child: child,
        vaccinated_at: Time.current,
        vaccine_name: "インフルエンザ"
      )
      expect(vaccination).to be_valid
    end

    it "vaccinated_at が無いと無効になる" do
      vaccination = Vaccination.new(
        user: user,
        child: child,
        vaccinated_at: nil,
        vaccine_name: "インフルエンザ"
      )
      expect(vaccination).to be_invalid
      expect(vaccination.errors[:vaccinated_at]).to include("を入力してください")
    end

    it "vaccine_name が無いと無効になる" do
      vaccination = Vaccination.new(
        user: user,
        child: child,
        vaccinated_at: Time.current,
        vaccine_name: nil
      )
      expect(vaccination).to be_invalid
      expect(vaccination.errors[:vaccine_name]).to include("を入力してください")
    end
  end

  describe "関連付け" do
    it "user が無いと無効になる" do
      vaccination = Vaccination.new(
        user: nil,
        child: child,
        vaccinated_at: Time.current,
        vaccine_name: "インフルエンザ"
      )
      expect(vaccination).to be_invalid
    end

    it "child が無いと無効になる" do
      vaccination = Vaccination.new(
        user: user,
        child: nil,
        vaccinated_at: Time.current,
        vaccine_name: "インフルエンザ"
      )
      expect(vaccination).to be_invalid
    end
  end
end
