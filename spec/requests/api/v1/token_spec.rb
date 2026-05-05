require 'rails_helper'

RSpec.describe 'Token API', type: :request do
  describe 'POST /api/v1/token' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns a token' do
        post '/api/v1/token', params: { email: 'test@example.com', password: 'password123' }

        expect(response).to have_http_status(:created)
        expect(json_response['token']).to be_present
        expect(json_response['user_id']).to eq(user.id)
      end

      it 'creates an auth session' do
        expect {
          post '/api/v1/token', params: { email: 'test@example.com', password: 'password123' }
        }.to change(AuthSession, :count).by(1)
      end
    end

    context 'with wrong password' do
      it 'returns unauthorized' do
        post '/api/v1/token', params: { email: 'test@example.com', password: 'wrong' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with non-existent email' do
      it 'returns unauthorized' do
        post '/api/v1/token', params: { email: 'nobody@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with unconfirmed user' do
      let!(:unconfirmed_user) { create(:user, email: 'unconfirmed@example.com', confirmed_at: nil) }

      it 'returns unauthorized' do
        post '/api/v1/token', params: { email: 'unconfirmed@example.com', password: 'password' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('User not confirmed')
      end
    end
  end

  describe 'DELETE /api/v1/token' do
    let(:user) { create(:user) }

    context 'with valid token' do
      it 'revokes the token' do
        headers = auth_headers(user)

        expect {
          delete '/api/v1/token', headers: headers
        }.to change(AuthSession, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end
    end

    context 'without token' do
      it 'returns unauthorized' do
        delete '/api/v1/token'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'with expired token' do
      it 'returns unauthorized' do
        session = create(:auth_session, user: user, expired_at: 1.day.ago)
        headers = { 'Authorization' => "Bearer #{session.token}" }

        delete '/api/v1/token', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized' do
        headers = { 'Authorization' => 'Bearer invalid-token' }

        delete '/api/v1/token', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end
end
