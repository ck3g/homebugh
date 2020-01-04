require 'rails_helper'

RSpec.describe 'API token', type: :request do
  describe 'POST /api/token' do
    let(:user_data) do
      {
        email: "user@example.com",
        password: "password"
      }
    end

    context "when user credentials are valid" do
      let!(:user) { create :user, email: "user@example.com", password: "password" }

      before do
        post "/api/token.json", params: { user: user_data }
      end

      it "responds with created" do
        expect(response.status).to eq 201
      end

      it "respond with the generated token" do
        expect(JSON.parse(response.body)).to eq(
          "token" => user.reload.access_token,
          "result" => "OK"
        )
      end

      it "populates the user token" do
        expect(user.reload.access_token).to be_present
      end
    end

    context "when user credentials are not valid" do
      before do
        post "/api/token.json", params: { user: user_data }
      end

      it "responds with unauthorized" do
        expect(response.status).to eq 401
      end

      it "does not generates any token" do
        expect(JSON.parse(response.body)).to eq(
          "result" => "Error",
          "message" => "Invalid E-Mail or Password"
        )
      end
    end
  end
end
