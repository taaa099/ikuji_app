require 'rails_helper'

RSpec.describe "Hydrations", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(HydrationsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /hydrations" do
    it "200 OK を返す" do
      get child_hydrations_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /hydrations/new" do
    it "200 OK を返す" do
      get new_child_hydration_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /hydrations" do
    let(:valid_params) do
      {
        hydration: {
          fed_at: Time.current,
          drink_type: "お水",
          memo: "メモ"
        }
      }
    end

    it "Hydration が作成されリダイレクトされる" do
      expect {
        post child_hydrations_path(child), params: valid_params
      }.to change { Hydration.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /hydrations/:id/edit" do
    let(:hydration) { child.hydrations.create!(fed_at: Time.current, drink_type: "お水", user: user) }

    it "200 OK を返す" do
      get edit_child_hydration_path(child, hydration)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /hydrations/:id" do
    let(:hydration) { child.hydrations.create!(fed_at: Time.current, drink_type: "お水", user: user) }
    it "Hydration が更新されリダイレクトされる" do
      patch child_hydration_path(child, hydration), params: {

        hydration: { drink_type: "お水", memo: "変更後", fed_at: hydration.fed_at }
      }
      expect(hydration.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /hydrations/:id" do
    let!(:hydration) { child.hydrations.create!(fed_at: Time.current, drink_type: "お水", user: user) }

    it "Hydration を削除しリダイレクトされる" do
      expect {
        delete child_hydration_path(child, hydration)
      }.to change { Hydration.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
