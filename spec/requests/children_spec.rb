require 'rails_helper'

RSpec.describe "Children", type: :request do
  let(:child) { Child.create(name: "テスト", birthday: Date.new(2020, 1, 1)) }

  describe "GET /index" do
    it "returns http success" do
      get "/children"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/children/#{child.id}"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/children/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /create" do
    it "creates a new child and redirects" do
      post "/children", params: { child: { name: "新しい子", birthday: "2020-01-01" } }
      expect(response).to redirect_to(assigns(:child)) # showにリダイレクトされる想定
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/children/#{child.id}/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates the child and redirects" do
      patch "/children/#{child.id}", params: { child: { name: "更新された名前" } }
      expect(response).to redirect_to(assigns(:child))
    end
  end

  describe "DELETE /destroy" do
    it "deletes the child and redirects" do
      delete "/children/#{child.id}"
      expect(response).to redirect_to(children_path)
    end
  end
end