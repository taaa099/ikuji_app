require 'rails_helper'

RSpec.describe "BabyFoods", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(BabyFoodsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /baby_foods" do
    it "200 OK を返す" do
      get child_baby_foods_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /baby_foods/new" do
    it "200 OK を返す" do
      get new_child_baby_food_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /baby_foods" do
    let(:valid_params) do
      {
        baby_food: {
          fed_at: Time.current,
          amount: 100,
          memo: "メモ"
        }
      }
    end

    it "BabyFood が作成されリダイレクトされる" do
      expect {
        post child_baby_foods_path(child), params: valid_params
      }.to change { BabyFood.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /baby_foods/:id/edit" do
    let(:baby_food) { child.baby_foods.create!(fed_at: Time.current, amount: 100, user: user) }

    it "200 OK を返す" do
      get edit_child_baby_food_path(child, baby_food)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /baby_foods/:id" do
    let(:baby_food) { child.baby_foods.create!(fed_at: Time.current, amount: 100, user: user) }
    it "BabyFood が更新されリダイレクトされる" do
      patch child_baby_food_path(child, baby_food), params: {

        baby_food: { amount: 100, memo: "変更後", fed_at: baby_food.fed_at }
      }
      expect(baby_food.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /baby_foods/:id" do
    let!(:baby_food) { child.baby_foods.create!(fed_at: Time.current, amount: 100, user: user) }

    it "BabyFood を削除しリダイレクトされる" do
      expect {
        delete child_baby_food_path(child, baby_food)
      }.to change { BabyFood.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
