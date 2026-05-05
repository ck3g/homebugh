require 'rails_helper'

RSpec.describe 'Sync API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency, funds: 1000.0) }
  let(:category) { create(:spending_category, user: user) }
  let(:income_category) { create(:income_category, user: user) }

  describe 'POST /api/v1/sync' do
    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/sync'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'push and pull' do
      it 'creates records and returns pull data' do
        server_txn = create(:transaction, user: user, account: account, category: category)

        post '/api/v1/sync', params: {
          last_synced_at: 1.day.ago.iso8601,
          changes: {
            transactions: {
              created: [
                { client_uuid: 'ios-t1', amount: 50.0, account_id: account.id, category_id: category.id, comment: 'From iOS' }
              ]
            }
          }
        }, headers: headers

        expect(response).to have_http_status(:ok)

        pushed = json_response['pushed']
        expect(pushed['transactions']['created'].length).to eq(1)
        expect(pushed['transactions']['created'].first['server_id']).to be_present

        pull = json_response['pull']
        expect(pull['transactions']).to be_an(Array)
        expect(pull).to have_key('has_more')
        expect(pull).to have_key('deletions')
      end
    end

    context 'pull only' do
      it 'returns all updated records since last sync' do
        txn = create(:transaction, user: user, account: account, category: category)

        post '/api/v1/sync', params: {
          last_synced_at: 1.day.ago.iso8601
        }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['pushed']).to eq({})

        pull = json_response['pull']
        txn_ids = pull['transactions'].map { |t| t['id'] }
        expect(txn_ids).to include(txn.id)
      end
    end

    context 'full sync (no last_synced_at)' do
      it 'returns all records' do
        old_txn = create(:transaction, user: user, account: account, category: category)
        old_txn.update_column(:updated_at, 1.year.ago)

        post '/api/v1/sync', params: { last_synced_at: nil }, headers: headers

        expect(response).to have_http_status(:ok)
        txn_ids = json_response['pull']['transactions'].map { |t| t['id'] }
        expect(txn_ids).to include(old_txn.id)
      end
    end

    context 'deletions in pull' do
      it 'includes server-side deletions' do
        SyncDeletion.create!(resource_type: 'Transaction', resource_id: 42, user_id: user.id, deleted_at: 1.hour.ago)

        post '/api/v1/sync', params: {
          last_synced_at: 1.day.ago.iso8601
        }, headers: headers

        deletions = json_response['pull']['deletions']
        expect(deletions.length).to eq(1)
        expect(deletions.first['resource_type']).to eq('Transaction')
        expect(deletions.first['resource_id']).to eq(42)
      end
    end

    context 'integration: multi-phase sync' do
      it 'handles a full sync flow with dependency ordering' do
        # Phase 1: push parent resources (categories)
        CategoryType.find_or_create_by!(id: CategoryType.expense, name: 'spending')

        post '/api/v1/sync', params: {
          last_synced_at: nil,
          changes: {
            categories: {
              created: [
                { client_uuid: 'ios-cat-1', name: 'iOS Groceries', category_type_id: CategoryType.expense }
              ]
            }
          }
        }, headers: headers

        expect(response).to have_http_status(:ok)
        cat_server_id = json_response['pushed']['categories']['created'].first['server_id']

        # Phase 2: push child resources using server IDs from phase 1
        post '/api/v1/sync', params: {
          last_synced_at: nil,
          changes: {
            transactions: {
              created: [
                { client_uuid: 'ios-txn-1', amount: 42.50, account_id: account.id, category_id: cat_server_id, comment: 'Milk and bread' }
              ]
            }
          }
        }, headers: headers

        expect(response).to have_http_status(:ok)
        txn_server_id = json_response['pushed']['transactions']['created'].first['server_id']

        # Verify the transaction was created correctly
        txn = Transaction.find(txn_server_id)
        expect(txn.summ).to eq(42.50)
        expect(txn.category_id).to eq(cat_server_id)
        expect(txn.user).to eq(user)

        # Verify account balance was adjusted
        expect(account.reload.funds).to eq(957.50)
      end

      it 'handles conflict resolution with last-write-wins' do
        txn = create(:transaction, user: user, account: account, category: category, comment: 'Server version')
        txn.update_column(:updated_at, 1.hour.ago)

        # iOS sends an older update — should be skipped
        post '/api/v1/sync', params: {
          last_synced_at: 2.days.ago.iso8601,
          changes: {
            transactions: {
              updated: [
                { id: txn.id, comment: 'iOS version', updated_at: 2.days.ago.iso8601 }
              ]
            }
          }
        }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['pushed']['transactions']['updated'].first['status']).to eq('skipped')
        expect(txn.reload.comment).to eq('Server version')
      end
    end
  end
end
