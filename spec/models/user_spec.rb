require 'rails_helper'

RSpec.describe User, type: :model do
  it "email, password があれば有効である" do
    user = User.new(email: "test@example.com", password: "password")
    expect(user).to be_valid
  end
end
