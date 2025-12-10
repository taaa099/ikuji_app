require 'rails_helper'

RSpec.describe "SleepRecords", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(SleepRecordsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /sleep_records" do
    it "200 OK を返す" do
      get child_sleep_records_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /sleep_records/new" do
    it "200 OK を返す" do
      get new_child_sleep_record_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /sleep_records" do
    let(:valid_params) do
      {
        sleep_record: {
          start_time: Time.current,
          end_time: Time.current + 1.hour,
          memo: "メモ"
        }
      }
    end

    it "SleepRecord が作成されリダイレクトされる" do
      expect {
        post child_sleep_records_path(child), params: valid_params
      }.to change { SleepRecord.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /sleep_records/:id/edit" do
    let(:sleep_record) { child.sleep_records.create!(start_time: Time.current, end_time: Time.current + 1.hour, user: user) }

    it "200 OK を返す" do
      get edit_child_sleep_record_path(child, sleep_record)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /sleep_records/:id" do
    let(:sleep_record) { child.sleep_records.create!(start_time: Time.current, end_time: Time.current + 1.hour, user: user) }
    it "SleepRecord が更新されリダイレクトされる" do
      patch child_sleep_record_path(child, sleep_record), params: {

        sleep_record: { end_time: Time.current + 1.hour, memo: "変更後", start_time: sleep_record.start_time }
      }
      expect(sleep_record.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /sleep_records/:id" do
    let!(:sleep_record) { child.sleep_records.create!(start_time: Time.current, end_time: Time.current + 1.hour, user: user) }

    it "SleepRecord を削除しリダイレクトされる" do
      expect {
        delete child_sleep_record_path(child, sleep_record)
      }.to change { SleepRecord.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
