require 'rails_helper'

RSpec.describe "Temperatures", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(TemperaturesController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /temperatures" do
    it "200 OK を返す" do
      get child_temperatures_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /temperatures/new" do
    it "200 OK を返す" do
      get new_child_temperature_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /temperatures" do
    let(:valid_params) do
      {
        temperature: {
          measured_at: Time.current,
          temperature: 37.0,
          memo: "メモ"
        }
      }
    end

    it "Temperature が作成されリダイレクトされる" do
      expect {
        post child_temperatures_path(child), params: valid_params
      }.to change { Temperature.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /temperatures/:id/edit" do
    let(:temperature) { child.temperatures.create!(measured_at: Time.current, temperature: 37.0, user: user) }

    it "200 OK を返す" do
      get edit_child_temperature_path(child, temperature)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /temperatures/:id" do
    let(:temperature) { child.temperatures.create!(measured_at: Time.current, temperature: 37.0, user: user) }
    it "Temperature が更新されリダイレクトされる" do
      patch child_temperature_path(child, temperature), params: {

        temperature: { temperature: 37.0, memo: "変更後", measured_at: temperature.measured_at }
      }
      expect(temperature.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /temperatures/:id" do
    let!(:temperature) { child.temperatures.create!(measured_at: Time.current, temperature: 37.0, user: user) }

    it "Temperature を削除しリダイレクトされる" do
      expect {
        delete child_temperature_path(child, temperature)
      }.to change { Temperature.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
