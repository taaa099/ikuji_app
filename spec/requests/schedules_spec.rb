require 'rails_helper'

RSpec.describe "Schedules", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(SchedulesController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /schedules" do
    it "200 OK を返す" do
      get schedules_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /schedules/new" do
    it "200 OK を返す" do
      get new_schedule_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /schedules" do
    let(:valid_params) do
      {
        schedule: {
          start_time: Time.current,
          end_time: Time.current + 1.hour,
          title: "タイトル",
          user_only: true,
          memo: "メモ"
        }
      }
    end

    it "Schedule が作成されリダイレクトされる" do
      expect {
        post schedules_path, params: valid_params
      }.to change { Schedule.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /schedules/:id/edit" do
    let(:schedule) { Schedule.create!(start_time: Time.current, end_time: Time.current + 1.hour, title: "タイトル", user_only: true, user: user) }

    it "200 OK を返す" do
      get edit_schedule_path(schedule)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /schedules/:id" do
    let(:schedule) { Schedule.create!(start_time: Time.current, end_time: Time.current + 1.hour, title: "タイトル", user_only: true, user: user) }
    it "Schedule が更新されリダイレクトされる" do
      patch schedule_path(schedule), params: {

        schedule: { end_time: Time.current + 1.hour, title: "タイトル", user_only: true, memo: "変更後", start_time: schedule.start_time }
      }
      expect(schedule.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /schedules/:id" do
    let!(:schedule) { Schedule.create!(start_time: Time.current, end_time: Time.current + 1.hour, title: "タイトル", user_only: true, user: user) }

    it "Schedule を削除しリダイレクトされる" do
      expect {
        delete schedule_path(schedule)
      }.to change { Schedule.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
