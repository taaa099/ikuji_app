require 'rails_helper'

RSpec.describe "Children", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/children/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/children/show"
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
    it "returns http success" do
      post "/children/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/children/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "returns http success" do
      patch "/children/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    it "returns http success" do
      delete "/children/destroy"
      expect(response).to have_http_status(:success)
    end
  end
end
