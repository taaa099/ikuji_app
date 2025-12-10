require 'rails_helper'

RSpec.describe "Diaries", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(DiariesController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /diaries" do
    it "200 OK を返す" do
      get diaries_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /diaries/new" do
    it "200 OK を返す" do
      get new_diary_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /diaries" do
    let(:valid_params) do
      {
        diary: {
          date: Time.current,
          title: "タイトル",
          content: "内容"
        }
      }
    end

    it "Diary が作成されリダイレクトされる" do
      expect {
        post diaries_path, params: valid_params
      }.to change { Diary.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /diaries/:id/edit" do
    let(:diary) { Diary.create!(date: Time.current, title: "タイトル", content: "内容", user: user) }

    it "200 OK を返す" do
      get edit_diary_path(diary)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /diaries/:id" do
    let(:diary) { Diary.create!(date: Time.current, title: "タイトル", content: "内容", user: user) }
    it "Diary が更新されリダイレクトされる" do
      patch diary_path(diary), params: {

        diary: { title: "タイトル", content: "内容", date: diary.date }
      }
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /diaries/:id" do
    let!(:diary) { Diary.create!(date: Time.current, title: "タイトル", content: "内容", user: user) }

    it "Diary を削除しリダイレクトされる" do
      expect {
        delete diary_path(diary)
      }.to change { Diary.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
