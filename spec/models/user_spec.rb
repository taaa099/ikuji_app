require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with a valid email and password" do
    user = User.new(email: "test@example.com", password: "password")
    expect(user).to be_valid
  end
end