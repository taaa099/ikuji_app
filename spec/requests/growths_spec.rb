require 'rails_helper'

RSpec.describe "Growths", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(GrowthsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /growths" do
    it "200 OK を返す" do
      get child_growths_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /growths/new" do
    it "200 OK を返す" do
      get new_child_growth_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /growths" do
    let(:valid_params) do
      {
        growth: {
          recorded_at: Time.current,
          height: 60.5,
          weight: 6.5
        }
      }
    end

    it "Growth が作成されリダイレクトされる" do
      expect {
        post child_growths_path(child), params: valid_params
      }.to change { Growth.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /growths/:id/edit" do
    let(:growth) { child.growths.create!(recorded_at: Time.current, height: 60.5, weight: 6.5) }

    it "200 OK を返す" do
      get edit_child_growth_path(child, growth)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /growths/:id" do
    let(:growth) { child.growths.create!(recorded_at: Time.current, height: 60.5, weight: 6.5) }
    it "Growth が更新されリダイレクトされる" do
      patch child_growth_path(child, growth), params: {

        growth: { height: 60.5, weight: 6.5, recorded_at: growth.recorded_at }
      }
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /growths/:id" do
    let!(:growth) { child.growths.create!(recorded_at: Time.current, height: 60.5, weight: 6.5) }

    it "Growth を削除しリダイレクトされる" do
      expect {
        delete child_growth_path(child, growth)
      }.to change { Growth.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
