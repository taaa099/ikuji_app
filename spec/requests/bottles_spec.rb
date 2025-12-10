require 'rails_helper'

RSpec.describe "Bottles", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(BottlesController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /bottles" do
    it "200 OK を返す" do
      get child_bottles_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /bottles/new" do
    it "200 OK を返す" do
      get new_child_bottle_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /bottles" do
    let(:valid_params) do
      {
        bottle: {
          given_at: Time.current,
          amount: 100,
          memo: "メモ"
        }
      }
    end

    it "Bottle が作成されリダイレクトされる" do
      expect {
        post child_bottles_path(child), params: valid_params
      }.to change { Bottle.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /bottles/:id/edit" do
    let(:bottle) { child.bottles.create!(given_at: Time.current, amount: 100, user: user) }

    it "200 OK を返す" do
      get edit_child_bottle_path(child, bottle)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /bottles/:id" do
    let(:bottle) { child.bottles.create!(given_at: Time.current, amount: 100, user: user) }
    it "Bottle が更新されリダイレクトされる" do
      patch child_bottle_path(child, bottle), params: {

        bottle: { amount: 100, memo: "変更後", given_at: bottle.given_at }
      }
      expect(bottle.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /bottles/:id" do
    let!(:bottle) { child.bottles.create!(given_at: Time.current, amount: 100, user: user) }

    it "Bottle を削除しリダイレクトされる" do
      expect {
        delete child_bottle_path(child, bottle)
      }.to change { Bottle.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
