require 'rails_helper'

RSpec.describe 'Cash Flows API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:from_account) { create(:account, user: user, currency: currency, funds: 1000.00) }
  let(:to_account) { create(:account, user: user, currency: currency, funds: 500.00) }

  describe 'GET /api/v1/cash_flows' do
    context 'when authenticated' do
      let!(:cash_flow1) { create(:cash_flow, user: user, from_account: from_account, to_account: to_account) }
      let!(:cash_flow2) { create(:cash_flow, user: user, from_account: from_account, to_account: to_account) }
      let!(:other_cash_flow) { create(:cash_flow, user: other_user) }

      it 'returns cash flows for the current user only' do
        get '/api/v1/cash_flows', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['cash_flows'].map { |cf| cf['id'] }
        expect(ids).to contain_exactly(cash_flow1.id, cash_flow2.id)
        expect(ids).not_to include(other_cash_flow.id)
      end

      it 'returns cash flow attributes' do
        get '/api/v1/cash_flows', headers: headers

        cash_flow = json_response['cash_flows'].find { |cf| cf['id'] == cash_flow1.id }
        expect(cash_flow['amount']).to eq('55.0')
        expect(cash_flow['initial_amount']).to be_nil
        expect(cash_flow['from_account_id']).to eq(from_account.id)
        expect(cash_flow['to_account_id']).to eq(to_account.id)
        expect(cash_flow['client_uuid']).to be_nil
        expect(cash_flow['created_at']).to be_present
        expect(cash_flow['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/cash_flows', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['cash_flows'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        cash_flow1.update_column(:updated_at, 2.days.ago)
        cash_flow2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/cash_flows', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['cash_flows'].map { |cf| cf['id'] }
        expect(ids).to contain_exactly(cash_flow2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/cash_flows'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/cash_flows/:id' do
    let!(:cash_flow) { create(:cash_flow, user: user, from_account: from_account, to_account: to_account) }

    context 'when authenticated' do
      it 'returns the cash flow' do
        get "/api/v1/cash_flows/#{cash_flow.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(cash_flow.id)
      end

      it 'returns not found for another user cash flow' do
        other_cf = create(:cash_flow, user: other_user)

        get "/api/v1/cash_flows/#{other_cf.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found for non-existent cash flow' do
        get '/api/v1/cash_flows/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/cash_flows' do
    context 'when authenticated' do
      it 'creates a cash flow and adjusts both account balances' do
        expect {
          post '/api/v1/cash_flows', params: {
            amount: 200.00, from_account_id: from_account.id, to_account_id: to_account.id
          }, headers: headers
        }.to change(CashFlow, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['amount']).to eq('200.0')
        expect(from_account.reload.funds).to eq(800.00)
        expect(to_account.reload.funds).to eq(700.00)
      end

      it 'supports cross-currency with initial_amount' do
        post '/api/v1/cash_flows', params: {
          amount: 180.00, initial_amount: 200.00,
          from_account_id: from_account.id, to_account_id: to_account.id
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['initial_amount']).to eq('200.0')
        expect(from_account.reload.funds).to eq(800.00)
        expect(to_account.reload.funds).to eq(680.00)
      end

      it 'assigns the cash flow to the current user' do
        post '/api/v1/cash_flows', params: {
          amount: 50.0, from_account_id: from_account.id, to_account_id: to_account.id
        }, headers: headers

        expect(CashFlow.last.user).to eq(user)
      end

      it 'accepts client_uuid' do
        post '/api/v1/cash_flows', params: {
          amount: 50.0, from_account_id: from_account.id, to_account_id: to_account.id,
          client_uuid: 'ios-cf-uuid'
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-cf-uuid')
      end

      it 'returns validation error when accounts are equal' do
        post '/api/v1/cash_flows', params: {
          amount: 50.0, from_account_id: from_account.id, to_account_id: from_account.id
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
      end

      it 'returns validation error for missing amount' do
        post '/api/v1/cash_flows', params: {
          from_account_id: from_account.id, to_account_id: to_account.id
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/cash_flows', params: { amount: 50.0 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/cash_flows/:id' do
    context 'when authenticated' do
      it 'deletes the cash flow and reverses both balances' do
        cash_flow = create(:cash_flow, user: user, from_account: from_account, to_account: to_account, amount: 100.0)
        from_balance_after = from_account.reload.funds
        to_balance_after = to_account.reload.funds

        delete "/api/v1/cash_flows/#{cash_flow.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
        expect { cash_flow.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(from_account.reload.funds).to eq(from_balance_after + 100.0)
        expect(to_account.reload.funds).to eq(to_balance_after - 100.0)
      end

      it 'returns not found for another user cash flow' do
        other_cf = create(:cash_flow, user: other_user)

        delete "/api/v1/cash_flows/#{other_cf.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
