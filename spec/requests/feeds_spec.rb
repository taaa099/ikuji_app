require 'rails_helper'

RSpec.describe "Feeds", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(FeedsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /feeds" do
    it "200 OK を返す" do
      get child_feeds_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /feeds/new" do
    it "200 OK を返す" do
      get new_child_feed_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /feeds" do
    let(:valid_params) do
      {
        left_minutes: 1,
        left_seconds: 0,
        right_minutes: 0,
        right_seconds: 30,
        feed: {
          fed_at: Time.current,
          memo: "メモ"
        }
      }
    end

    it "Feed が作成されリダイレクトされる" do
      expect {
        post child_feeds_path(child), params: valid_params
      }.to change { Feed.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /feeds/:id/edit" do
    let(:feed) { child.feeds.create!(fed_at: Time.current, left_time: 60, user: user) }

    it "200 OK を返す" do
      get edit_child_feed_path(child, feed)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /feeds/:id" do
    let(:feed) { child.feeds.create!(fed_at: Time.current, left_time: 60, user: user) }
    it "Feed が更新されリダイレクトされる" do
      patch child_feed_path(child, feed), params: {
        left_minutes: 1,
        left_seconds: 0,
        right_minutes: 0,
        right_seconds: 0,
        feed: { memo: "変更後", fed_at: feed.fed_at }
      }
      expect(feed.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /feeds/:id" do
    let!(:feed) { child.feeds.create!(fed_at: Time.current, left_time: 60, user: user) }

    it "Feed を削除しリダイレクトされる" do
      expect {
        delete child_feed_path(child, feed)
      }.to change { Feed.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
