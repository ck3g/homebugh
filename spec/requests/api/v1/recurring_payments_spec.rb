require 'rails_helper'

RSpec.describe 'Recurring Payments API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency, funds: 1000.00) }
  let(:category) { create(:spending_category, user: user) }

  describe 'GET /api/v1/recurring_payments' do
    context 'when authenticated' do
      let!(:rp1) { create(:recurring_payment, user: user, account: account, category: category) }
      let!(:rp2) { create(:recurring_payment, user: user, account: account, category: category) }
      let!(:other_rp) { create(:recurring_payment, user: other_user) }

      it 'returns recurring payments for the current user only' do
        get '/api/v1/recurring_payments', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['recurring_payments'].map { |rp| rp['id'] }
        expect(ids).to contain_exactly(rp1.id, rp2.id)
        expect(ids).not_to include(other_rp.id)
      end

      it 'returns recurring payment attributes' do
        get '/api/v1/recurring_payments', headers: headers

        rp = json_response['recurring_payments'].find { |r| r['id'] == rp1.id }
        expect(rp['title']).to eq('Rent')
        expect(rp['amount']).to eq('503.0')
        expect(rp['account_id']).to eq(account.id)
        expect(rp['category_id']).to eq(category.id)
        expect(rp['frequency']).to eq('monthly')
        expect(rp['frequency_amount']).to eq(1)
        expect(rp['next_payment_on']).to be_present
        expect(rp['ends_on']).to be_nil
        expect(rp['client_uuid']).to be_nil
        expect(rp['created_at']).to be_present
        expect(rp['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/recurring_payments', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['recurring_payments'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        rp1.update_column(:updated_at, 2.days.ago)
        rp2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/recurring_payments', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['recurring_payments'].map { |rp| rp['id'] }
        expect(ids).to contain_exactly(rp2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/recurring_payments'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/recurring_payments/:id' do
    let!(:rp) { create(:recurring_payment, user: user, account: account, category: category) }

    context 'when authenticated' do
      it 'returns the recurring payment' do
        get "/api/v1/recurring_payments/#{rp.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(rp.id)
        expect(json_response['title']).to eq('Rent')
      end

      it 'returns not found for another user recurring payment' do
        other_rp = create(:recurring_payment, user: other_user)

        get "/api/v1/recurring_payments/#{other_rp.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/recurring_payments' do
    context 'when authenticated' do
      let(:valid_params) do
        {
          title: 'Netflix',
          amount: 15.99,
          account_id: account.id,
          category_id: category.id,
          frequency: 'monthly',
          frequency_amount: 1,
          next_payment_on: 1.month.from_now.to_date.to_s
        }
      end

      it 'creates a recurring payment' do
        expect {
          post '/api/v1/recurring_payments', params: valid_params, headers: headers
        }.to change(RecurringPayment, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['title']).to eq('Netflix')
        expect(json_response['amount']).to eq('15.99')
        expect(json_response['frequency']).to eq('monthly')
      end

      it 'accepts client_uuid' do
        post '/api/v1/recurring_payments', params: valid_params.merge(client_uuid: 'ios-rp-uuid'), headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-rp-uuid')
      end

      it 'returns validation errors for missing title' do
        post '/api/v1/recurring_payments', params: valid_params.except(:title), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/recurring_payments', params: { title: 'Test' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/recurring_payments/:id' do
    let!(:rp) { create(:recurring_payment, user: user, account: account, category: category, title: 'Old Title') }

    context 'when authenticated' do
      it 'updates the recurring payment' do
        patch "/api/v1/recurring_payments/#{rp.id}", params: { title: 'New Title', amount: 25.00 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['title']).to eq('New Title')
        expect(json_response['amount']).to eq('25.0')
      end

      it 'returns not found for another user recurring payment' do
        other_rp = create(:recurring_payment, user: other_user)

        patch "/api/v1/recurring_payments/#{other_rp.id}", params: { title: 'Hacked' }, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/recurring_payments/:id' do
    context 'when authenticated' do
      let!(:rp) { create(:recurring_payment, user: user, account: account, category: category) }

      it 'deletes the recurring payment' do
        expect {
          delete "/api/v1/recurring_payments/#{rp.id}", headers: headers
        }.to change(RecurringPayment, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end

      it 'returns not found for another user recurring payment' do
        other_rp = create(:recurring_payment, user: other_user)

        delete "/api/v1/recurring_payments/#{other_rp.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /api/v1/recurring_payments/:id/move_to_next_payment' do
    context 'when authenticated' do
      let!(:rp) { create(:recurring_payment, user: user, account: account, category: category, frequency: 'monthly', frequency_amount: 1) }

      it 'advances next_payment_on' do
        original_date = rp.next_payment_on

        put "/api/v1/recurring_payments/#{rp.id}/move_to_next_payment", headers: headers

        expect(response).to have_http_status(:ok)
        expect(Date.parse(json_response['next_payment_on'])).to eq(original_date + 1.month)
      end

      it 'returns not found for another user recurring payment' do
        other_rp = create(:recurring_payment, user: other_user)

        put "/api/v1/recurring_payments/#{other_rp.id}/move_to_next_payment", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/recurring_payments/:id/create_transaction' do
    context 'when authenticated' do
      let!(:rp) { create(:recurring_payment, user: user, account: account, category: category, amount: 50.0, frequency: 'monthly', frequency_amount: 1) }

      it 'creates a transaction and advances the schedule' do
        original_date = rp.next_payment_on

        expect {
          post "/api/v1/recurring_payments/#{rp.id}/create_transaction", headers: headers
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['amount']).to eq('50.0')
        expect(rp.reload.next_payment_on).to eq(original_date + 1.month)
      end

      it 'adjusts account balance' do
        post "/api/v1/recurring_payments/#{rp.id}/create_transaction", headers: headers

        expect(account.reload.funds).to eq(950.0)
      end

      it 'returns not found for another user recurring payment' do
        other_rp = create(:recurring_payment, user: other_user)

        post "/api/v1/recurring_payments/#{other_rp.id}/create_transaction", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
