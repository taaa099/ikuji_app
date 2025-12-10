require 'rails_helper'

RSpec.describe "Vaccinations", type: :request do
  let(:user)  { User.create!(name: "ユーザー", email: "a@example.com", password: "password") }
  let(:child) { Child.create!(name: "baby", birth_date: "2025-01-01", gender: "男") }

  before do
    user.save!
    sign_in(user, scope: :user)

    allow_any_instance_of(VaccinationsController)
      .to receive(:current_child)
      .and_return(child)
  end

  describe "GET /vaccinations" do
    it "200 OK を返す" do
      get child_vaccinations_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /vaccinations/new" do
    it "200 OK を返す" do
      get new_child_vaccination_path(child)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /vaccinations" do
    let(:valid_params) do
      {
        vaccination: {
          vaccinated_at: Time.current,
          vaccine_name: "インフルエンザ",
          memo: "メモ"
        }
      }
    end

    it "Vaccination が作成されリダイレクトされる" do
      expect {
        post child_vaccinations_path(child), params: valid_params
      }.to change { Vaccination.count }.by(1)

      expect(response).to have_http_status(:found)
    end
  end

  describe "GET /vaccinations/:id/edit" do
    let(:vaccination) { child.vaccinations.create!(vaccinated_at: Time.current, vaccine_name: "インフルエンザ", user: user) }

    it "200 OK を返す" do
      get edit_child_vaccination_path(child, vaccination)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /vaccinations/:id" do
    let(:vaccination) { child.vaccinations.create!(vaccinated_at: Time.current, vaccine_name: "インフルエンザ", user: user) }
    it "Vaccination が更新されリダイレクトされる" do
      patch child_vaccination_path(child, vaccination), params: {

        vaccination: { vaccine_name: "インフルエンザ", memo: "変更後", vaccinated_at: vaccination.vaccinated_at }
      }
      expect(vaccination.reload.memo).to eq("変更後")
      expect(response).to have_http_status(:found)
    end
  end

  describe "DELETE /vaccinations/:id" do
    let!(:vaccination) { child.vaccinations.create!(vaccinated_at: Time.current, vaccine_name: "インフルエンザ", user: user) }

    it "Vaccination を削除しリダイレクトされる" do
      expect {
        delete child_vaccination_path(child, vaccination)
      }.to change { Vaccination.count }.by(-1)

      expect(response).to have_http_status(:found)
    end
  end
end
