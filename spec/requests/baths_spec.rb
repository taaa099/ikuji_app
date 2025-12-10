require 'rails_helper'

RSpec.describe "Baths", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(BathsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /baths" do
    it "200 OK を返す" do
      get child_baths_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /baths/new" do
    it "200 OK を返す" do
      get new_child_bath_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /baths" do
    let(:valid_params) do
      {
        bath: {
          bathed_at: Time.current,
          bath_type: "お風呂",
          memo: "メモ"
        }
      }
    end

    it "Bath が作成されリダイレクトされる" do
      expect {
        post child_baths_path(child), params: valid_params
      }.to change { Bath.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /baths/:id/edit" do
    let(:bath) { child.baths.create!(bathed_at: Time.current, bath_type: "お風呂", user: user) }

    it "200 OK を返す" do
      get edit_child_bath_path(child, bath)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /baths/:id" do
    let(:bath) { child.baths.create!(bathed_at: Time.current, bath_type: "お風呂", user: user) }
    it "Bath が更新されリダイレクトされる" do
      patch child_bath_path(child, bath), params: {

        bath: { bath_type: "お風呂", memo: "変更後", bathed_at: bath.bathed_at }
      }
      expect(bath.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /baths/:id" do
    let!(:bath) { child.baths.create!(bathed_at: Time.current, bath_type: "お風呂", user: user) }

    it "Bath を削除しリダイレクトされる" do
      expect {
        delete child_bath_path(child, bath)
      }.to change { Bath.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
