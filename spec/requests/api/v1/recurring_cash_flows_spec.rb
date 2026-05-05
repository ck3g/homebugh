require 'rails_helper'

RSpec.describe 'Recurring Cash Flows API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:from_account) { create(:account, user: user, currency: currency, funds: 1000.00) }
  let(:to_account) { create(:account, user: user, currency: currency, funds: 500.00) }

  describe 'GET /api/v1/recurring_cash_flows' do
    context 'when authenticated' do
      let!(:rcf1) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account) }
      let!(:rcf2) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account) }
      let!(:other_rcf) { create(:recurring_cash_flow, user: other_user) }

      it 'returns recurring cash flows for the current user only' do
        get '/api/v1/recurring_cash_flows', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['recurring_cash_flows'].map { |rcf| rcf['id'] }
        expect(ids).to contain_exactly(rcf1.id, rcf2.id)
        expect(ids).not_to include(other_rcf.id)
      end

      it 'returns recurring cash flow attributes' do
        get '/api/v1/recurring_cash_flows', headers: headers

        rcf = json_response['recurring_cash_flows'].find { |r| r['id'] == rcf1.id }
        expect(rcf['amount']).to eq('100.0')
        expect(rcf['from_account_id']).to eq(from_account.id)
        expect(rcf['to_account_id']).to eq(to_account.id)
        expect(rcf['frequency']).to eq('monthly')
        expect(rcf['frequency_amount']).to eq(1)
        expect(rcf['next_transfer_on']).to be_present
        expect(rcf['ends_on']).to be_nil
        expect(rcf['client_uuid']).to be_nil
        expect(rcf['created_at']).to be_present
        expect(rcf['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/recurring_cash_flows', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['recurring_cash_flows'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        rcf1.update_column(:updated_at, 2.days.ago)
        rcf2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/recurring_cash_flows', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['recurring_cash_flows'].map { |rcf| rcf['id'] }
        expect(ids).to contain_exactly(rcf2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/recurring_cash_flows'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/recurring_cash_flows/:id' do
    let!(:rcf) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account) }

    context 'when authenticated' do
      it 'returns the recurring cash flow' do
        get "/api/v1/recurring_cash_flows/#{rcf.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(rcf.id)
      end

      it 'returns not found for another user recurring cash flow' do
        other_rcf = create(:recurring_cash_flow, user: other_user)

        get "/api/v1/recurring_cash_flows/#{other_rcf.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/recurring_cash_flows' do
    context 'when authenticated' do
      let(:valid_params) do
        {
          amount: 200.00,
          from_account_id: from_account.id,
          to_account_id: to_account.id,
          frequency: 'monthly',
          frequency_amount: 1,
          next_transfer_on: 1.month.from_now.to_date.to_s
        }
      end

      it 'creates a recurring cash flow' do
        expect {
          post '/api/v1/recurring_cash_flows', params: valid_params, headers: headers
        }.to change(RecurringCashFlow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['amount']).to eq('200.0')
        expect(json_response['frequency']).to eq('monthly')
      end

      it 'accepts client_uuid' do
        post '/api/v1/recurring_cash_flows', params: valid_params.merge(client_uuid: 'ios-rcf-uuid'), headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-rcf-uuid')
      end

      it 'returns validation error when accounts are equal' do
        post '/api/v1/recurring_cash_flows', params: valid_params.merge(to_account_id: from_account.id), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/recurring_cash_flows', params: { amount: 100 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/recurring_cash_flows/:id' do
    let!(:rcf) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account, amount: 100.0) }

    context 'when authenticated' do
      it 'updates the recurring cash flow' do
        patch "/api/v1/recurring_cash_flows/#{rcf.id}", params: { amount: 250.00 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['amount']).to eq('250.0')
      end

      it 'returns not found for another user recurring cash flow' do
        other_rcf = create(:recurring_cash_flow, user: other_user)

        patch "/api/v1/recurring_cash_flows/#{other_rcf.id}", params: { amount: 999 }, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/recurring_cash_flows/:id' do
    context 'when authenticated' do
      let!(:rcf) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account) }

      it 'deletes the recurring cash flow' do
        expect {
          delete "/api/v1/recurring_cash_flows/#{rcf.id}", headers: headers
        }.to change(RecurringCashFlow, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end

      it 'returns not found for another user recurring cash flow' do
        other_rcf = create(:recurring_cash_flow, user: other_user)

        delete "/api/v1/recurring_cash_flows/#{other_rcf.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /api/v1/recurring_cash_flows/:id/move_to_next_transfer' do
    context 'when authenticated' do
      let!(:rcf) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account, frequency: 'monthly', frequency_amount: 1) }

      it 'advances next_transfer_on' do
        original_date = rcf.next_transfer_on

        put "/api/v1/recurring_cash_flows/#{rcf.id}/move_to_next_transfer", headers: headers

        expect(response).to have_http_status(:ok)
        expect(Date.parse(json_response['next_transfer_on'])).to eq(original_date + 1.month)
      end

      it 'returns not found for another user recurring cash flow' do
        other_rcf = create(:recurring_cash_flow, user: other_user)

        put "/api/v1/recurring_cash_flows/#{other_rcf.id}/move_to_next_transfer", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/recurring_cash_flows/:id/perform_transfer' do
    context 'when authenticated' do
      let!(:rcf) { create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account, amount: 150.0, frequency: 'monthly', frequency_amount: 1) }

      it 'creates a cash flow and advances the schedule' do
        original_date = rcf.next_transfer_on

        expect {
          post "/api/v1/recurring_cash_flows/#{rcf.id}/perform_transfer", headers: headers
        }.to change(CashFlow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['amount']).to eq('150.0')
        expect(rcf.reload.next_transfer_on).to eq(original_date + 1.month)
      end

      it 'adjusts both account balances' do
        post "/api/v1/recurring_cash_flows/#{rcf.id}/perform_transfer", headers: headers

        expect(from_account.reload.funds).to eq(850.0)
        expect(to_account.reload.funds).to eq(650.0)
      end

      it 'returns not found for another user recurring cash flow' do
        other_rcf = create(:recurring_cash_flow, user: other_user)

        post "/api/v1/recurring_cash_flows/#{other_rcf.id}/perform_transfer", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
