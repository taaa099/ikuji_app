require 'rails_helper'

RSpec.describe "Children", type: :request do
  let(:user) { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { user.children.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    sign_in(user)

    allow_any_instance_of(ChildrenController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /children" do
    it "200 OK を返す" do
      get children_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /children/new" do
    it "200 OK を返す" do
      get new_child_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /children" do
    let(:valid_params) { { child: { name: "baby", birth_date: "2025-01-01", gender: "男" } } }

    it "Child が作成されリダイレクトされる" do
      expect {
        post children_path, params: valid_params
      }.to change { user.children.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /children/:id/edit" do
    let(:child) { user.children.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

    it "200 OK を返す" do
      get edit_child_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /children/:id" do
    let(:child) { user.children.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

    it "Child が更新されリダイレクトされる" do
      patch child_path(child), params: { child: { name: "new_name" } }
      expect(child.reload.name).to eq("new_name")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /children/:id" do
    let!(:child) { user.children.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

    it "Child を削除しリダイレクトされる" do
      expect {
        delete child_path(child)
      }.to change { user.children.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
