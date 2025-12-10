require 'rails_helper'

RSpec.describe "Diapers", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(DiapersController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /diapers" do
    it "200 OK を返す" do
      get child_diapers_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /diapers/new" do
    it "200 OK を返す" do
      get new_child_diaper_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /diapers" do
    let(:valid_params) do
      {
        diaper: {
          changed_at: Time.current,
          pee: true,
          poop: false,
          memo: "メモ"
        }
      }
    end

    it "Diaper が作成されリダイレクトされる" do
      expect {
        post child_diapers_path(child), params: valid_params
      }.to change { Diaper.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /diapers/:id/edit" do
    let(:diaper) { child.diapers.create!(changed_at: Time.current, pee: true, user: user) }

    it "200 OK を返す" do
      get edit_child_diaper_path(child, diaper)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /diapers/:id" do
    let(:diaper) { child.diapers.create!(changed_at: Time.current, pee: true, user: user) }
    it "Diaper が更新されリダイレクトされる" do
      patch child_diaper_path(child, diaper), params: {

        diaper: { pee: "true", poop: "false", memo: "変更後", changed_at: diaper.changed_at }
      }
      expect(diaper.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /diapers/:id" do
    let!(:diaper) { child.diapers.create!(changed_at: Time.current, pee: true, user: user) }

    it "Diaper を削除しリダイレクトされる" do
      expect {
        delete child_diaper_path(child, diaper)
      }.to change { Diaper.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
