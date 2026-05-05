require 'rails_helper'

RSpec.describe 'Transactions API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency, funds: 1000.00) }
  let(:income_category) { create(:income_category, user: user) }
  let(:expense_category) { create(:spending_category, user: user) }

  describe 'GET /api/v1/transactions' do
    context 'when authenticated' do
      let!(:transaction1) { create(:transaction, user: user, account: account, category: expense_category, summ: 50.0) }
      let!(:transaction2) { create(:transaction, user: user, account: account, category: income_category, summ: 100.0) }
      let!(:other_transaction) { create(:transaction, user: other_user) }

      it 'returns transactions for the current user only' do
        get '/api/v1/transactions', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['transactions'].map { |t| t['id'] }
        expect(ids).to contain_exactly(transaction1.id, transaction2.id)
        expect(ids).not_to include(other_transaction.id)
      end

      it 'returns transaction attributes with amount field' do
        get '/api/v1/transactions', headers: headers

        transaction = json_response['transactions'].find { |t| t['id'] == transaction1.id }
        expect(transaction['amount']).to eq('50.0')
        expect(transaction['comment']).to eq('Comment')
        expect(transaction['account_id']).to eq(account.id)
        expect(transaction['category_id']).to eq(expense_category.id)
        expect(transaction['client_uuid']).to be_nil
        expect(transaction['created_at']).to be_present
        expect(transaction['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/transactions', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['transactions'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        transaction1.update_column(:updated_at, 2.days.ago)
        transaction2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/transactions', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['transactions'].map { |t| t['id'] }
        expect(ids).to contain_exactly(transaction2.id)
      end

      it 'supports account_id filter' do
        other_account = create(:account, user: user, currency: currency)
        other_txn = create(:transaction, user: user, account: other_account, category: expense_category)

        get '/api/v1/transactions', params: { account_id: account.id }, headers: headers

        ids = json_response['transactions'].map { |t| t['id'] }
        expect(ids).to include(transaction1.id)
        expect(ids).not_to include(other_txn.id)
      end

      it 'supports category_id filter' do
        get '/api/v1/transactions', params: { category_id: income_category.id }, headers: headers

        ids = json_response['transactions'].map { |t| t['id'] }
        expect(ids).to contain_exactly(transaction2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/transactions'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/transactions/:id' do
    let!(:transaction) { create(:transaction, user: user, account: account, category: expense_category) }

    context 'when authenticated' do
      it 'returns the transaction' do
        get "/api/v1/transactions/#{transaction.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(transaction.id)
        expect(json_response['amount']).to eq('10.0')
      end

      it 'returns not found for another user transaction' do
        other_txn = create(:transaction, user: other_user)

        get "/api/v1/transactions/#{other_txn.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found for non-existent transaction' do
        get '/api/v1/transactions/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/transactions' do
    context 'when authenticated' do
      it 'creates an expense transaction and withdraws from account' do
        expect {
          post '/api/v1/transactions', params: {
            amount: 75.50, account_id: account.id, category_id: expense_category.id, comment: 'Lunch'
          }, headers: headers
        }.to change(Transaction, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['amount']).to eq('75.5')
        expect(json_response['comment']).to eq('Lunch')
        expect(account.reload.funds).to eq(924.50)
      end

      it 'creates an income transaction and deposits to account' do
        post '/api/v1/transactions', params: {
          amount: 200.00, account_id: account.id, category_id: income_category.id
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(account.reload.funds).to eq(1200.00)
      end

      it 'assigns the transaction to the current user' do
        post '/api/v1/transactions', params: {
          amount: 10.0, account_id: account.id, category_id: expense_category.id
        }, headers: headers

        expect(Transaction.last.user).to eq(user)
      end

      it 'accepts client_uuid' do
        post '/api/v1/transactions', params: {
          amount: 10.0, account_id: account.id, category_id: expense_category.id,
          client_uuid: 'ios-uuid-789'
        }, headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-uuid-789')
      end

      it 'returns validation errors for missing amount' do
        post '/api/v1/transactions', params: {
          account_id: account.id, category_id: expense_category.id
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
      end

      it 'returns validation errors for amount less than 0.01' do
        post '/api/v1/transactions', params: {
          amount: 0.0, account_id: account.id, category_id: expense_category.id
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/transactions', params: { amount: 10.0 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/transactions/:id' do
    let!(:transaction) { create(:transaction, user: user, account: account, category: expense_category, comment: 'Old comment') }

    context 'when authenticated' do
      it 'updates the comment' do
        patch "/api/v1/transactions/#{transaction.id}", params: { comment: 'New comment' }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['comment']).to eq('New comment')
        expect(transaction.reload.comment).to eq('New comment')
      end

      it 'returns not found for another user transaction' do
        other_txn = create(:transaction, user: other_user)

        patch "/api/v1/transactions/#{other_txn.id}", params: { comment: 'Hacked' }, headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/transactions/:id' do
    context 'when authenticated' do
      it 'deletes the transaction and reverses the balance' do
        transaction = create(:transaction, user: user, account: account, category: expense_category, summ: 50.0)
        balance_after_create = account.reload.funds

        delete "/api/v1/transactions/#{transaction.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
        expect { transaction.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(account.reload.funds).to eq(balance_after_create + 50.0)
      end

      it 'returns not found for another user transaction' do
        other_txn = create(:transaction, user: other_user)

        delete "/api/v1/transactions/#{other_txn.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
