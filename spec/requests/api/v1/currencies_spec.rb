require 'rails_helper'

RSpec.describe 'Currencies API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/currencies' do
    context 'when authenticated' do
      let!(:usd) { create(:currency, name: 'US Dollar', unit: '$') }
      let!(:eur) { create(:currency, name: 'Euro', unit: '€') }

      it 'returns all currencies' do
        get '/api/v1/currencies', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['currencies'].length).to eq(2)
      end

      it 'returns currency attributes' do
        get '/api/v1/currencies', headers: headers

        currency = json_response['currencies'].find { |c| c['name'] == 'US Dollar' }
        expect(currency['id']).to eq(usd.id)
        expect(currency['name']).to eq('US Dollar')
        expect(currency['unit']).to eq('$')
        expect(currency['created_at']).to be_present
        expect(currency['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/currencies', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['currencies'].length).to eq(1)
        expect(json_response['meta']['current_page']).to eq(1)
        expect(json_response['meta']['per_page']).to eq(1)
        expect(json_response['meta']['total_pages']).to eq(2)
        expect(json_response['meta']['total_count']).to eq(2)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/currencies'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/currencies/:id' do
    let!(:usd) { create(:currency, name: 'US Dollar', unit: '$') }

    context 'when authenticated' do
      it 'returns the currency' do
        get "/api/v1/currencies/#{usd.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(usd.id)
        expect(json_response['name']).to eq('US Dollar')
        expect(json_response['unit']).to eq('$')
      end

      it 'returns not found for non-existent currency' do
        get '/api/v1/currencies/99999', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get "/api/v1/currencies/#{usd.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
