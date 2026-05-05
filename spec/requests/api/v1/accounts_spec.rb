require 'rails_helper'

RSpec.describe 'Accounts API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency, name: 'US Dollar', unit: '$') }

  describe 'GET /api/v1/accounts' do
    context 'when authenticated' do
      let!(:account1) { create(:account, user: user, currency: currency) }
      let!(:account2) { create(:account, user: user, currency: currency) }
      let!(:other_account) { create(:account, user: other_user) }

      it 'returns accounts for the current user only' do
        get '/api/v1/accounts', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['accounts'].map { |a| a['id'] }
        expect(ids).to contain_exactly(account1.id, account2.id)
        expect(ids).not_to include(other_account.id)
      end

      it 'returns account attributes with balance field' do
        account1.update_column(:funds, 1500.50)

        get '/api/v1/accounts', headers: headers

        account = json_response['accounts'].find { |a| a['id'] == account1.id }
        expect(account['name']).to eq(account1.name)
        expect(account['balance']).to eq('1500.5')
        expect(account['currency_id']).to eq(currency.id)
        expect(account['status']).to eq('active')
        expect(account['show_in_summary']).to eq(true)
        expect(account['client_uuid']).to be_nil
        expect(account['created_at']).to be_present
        expect(account['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/accounts', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['accounts'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        account1.update_column(:updated_at, 2.days.ago)
        account2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/accounts', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['accounts'].map { |a| a['id'] }
        expect(ids).to contain_exactly(account2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/accounts'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/accounts/:id' do
    let!(:account) { create(:account, user: user, currency: currency) }

    context 'when authenticated' do
      it 'returns the account' do
        get "/api/v1/accounts/#{account.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(account.id)
        expect(json_response['name']).to eq(account.name)
      end

      it 'returns not found for another user account' do
        other_account = create(:account, user: other_user)

        get "/api/v1/accounts/#{other_account.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found for non-existent account' do
        get '/api/v1/accounts/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/accounts' do
    context 'when authenticated' do
      let(:valid_params) do
        { name: 'Savings', currency_id: currency.id }
      end

      it 'creates an account' do
        expect {
          post '/api/v1/accounts', params: valid_params, headers: headers
        }.to change(Account, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['name']).to eq('Savings')
        expect(json_response['currency_id']).to eq(currency.id)
        expect(json_response['balance']).to eq('0.0')
      end

      it 'assigns the account to the current user' do
        post '/api/v1/accounts', params: valid_params, headers: headers

        expect(Account.last.user).to eq(user)
      end

      it 'accepts client_uuid and show_in_summary' do
        post '/api/v1/accounts', params: valid_params.merge(client_uuid: 'ios-uuid-456', show_in_summary: false), headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-uuid-456')
        expect(json_response['show_in_summary']).to eq(false)
      end

      it 'returns validation errors for missing name' do
        post '/api/v1/accounts', params: { currency_id: currency.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
        expect(json_response['details']['name']).to be_present
      end

      it 'returns validation errors for duplicate name within same currency' do
        create(:account, name: 'Savings', currency: currency, user: user)

        post '/api/v1/accounts', params: valid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']['name']).to be_present
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/accounts', params: { name: 'Test' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/accounts/:id' do
    let!(:account) { create(:account, name: 'Old Name', user: user, currency: currency) }

    context 'when authenticated' do
      it 'updates the account name' do
        patch "/api/v1/accounts/#{account.id}", params: { name: 'New Name' }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['name']).to eq('New Name')
        expect(account.reload.name).to eq('New Name')
      end

      it 'updates show_in_summary' do
        patch "/api/v1/accounts/#{account.id}", params: { show_in_summary: false }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['show_in_summary']).to eq(false)
      end

      it 'returns not found for another user account' do
        other_account = create(:account, user: other_user)

        patch "/api/v1/accounts/#{other_account.id}", params: { name: 'Hacked' }, headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns validation errors for blank name' do
        patch "/api/v1/accounts/#{account.id}", params: { name: '' }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']['name']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/accounts/:id' do
    context 'when authenticated' do
      it 'soft-deletes the account with zero balance' do
        account = create(:account, user: user, currency: currency, funds: 0)

        delete "/api/v1/accounts/#{account.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
        expect(account.reload.status).to eq('deleted')
      end

      it 'does not delete account with non-zero balance' do
        account = create(:account, user: user, currency: currency, funds: 100.00)

        delete "/api/v1/accounts/#{account.id}", headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to be_present
        expect(account.reload.status).to eq('active')
      end

      it 'returns not found for another user account' do
        other_account = create(:account, user: other_user)

        delete "/api/v1/accounts/#{other_account.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
