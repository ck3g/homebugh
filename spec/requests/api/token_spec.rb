require 'rails_helper'

RSpec.describe 'API token', type: :request do
  describe 'POST /api/token' do
    let(:user_data) do
      {
        email: "user@example.com",
        password: "password"
      }
    end

    before do
      post "/api/token.json", user: user_data
    end

    it "generates a new token" do
      expect(response.status).to eq 201
    end

    it "respond with the generated token" do
      expect(JSON.parse(response.body)).to eq(
        "token" => "123",
        "result" => "OK"
      )
    end
  end
end
