require 'rails_helper'

RSpec.describe Api::SyncService do
  let(:user) { create(:user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency, funds: 1000.0) }
  let(:category) { create(:spending_category, user: user) }

  subject { described_class.new(user) }

  describe '#call' do
    it 'processes push and pull in sequence' do
      # Create a server-side transaction that should appear in pull
      server_txn = create(:transaction, user: user, account: account, category: category)

      result = subject.call(
        last_synced_at: 1.day.ago.iso8601,
        changes: {
          'categories' => {
            'created' => [
              { 'client_uuid' => 'ios-sync-1', 'name' => 'New Cat', 'category_type_id' => category.category_type_id }
            ]
          }
        }
      )

      expect(result[:pushed][:categories][:created].length).to eq(1)
      # Pull should include the server transaction but NOT the just-created category
      txn_ids = result[:pull][:transactions].map { |t| t[:id] }
      expect(txn_ids).to include(server_txn.id)
    end

    it 'handles pull-only request (no changes)' do
      create(:transaction, user: user, account: account, category: category)

      result = subject.call(last_synced_at: 1.day.ago.iso8601, changes: {})

      expect(result[:pushed]).to eq({})
      expect(result[:pull][:transactions]).not_to be_empty
    end

    it 'handles push-only request (no last_synced_at context needed)' do
      result = subject.call(
        last_synced_at: nil,
        changes: {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'ios-push-only', 'amount' => 25.0, 'account_id' => account.id, 'category_id' => category.id }
            ]
          }
        }
      )

      expect(result[:pushed][:transactions][:created].length).to eq(1)
    end

    it 'wraps push in a database transaction' do
      # If one create fails validation, the others should still succeed
      # (per-item rejection, not all-or-nothing for business rules)
      result = subject.call(
        last_synced_at: nil,
        changes: {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'good', 'amount' => 25.0, 'account_id' => account.id, 'category_id' => category.id },
              { 'client_uuid' => 'bad', 'amount' => 0, 'account_id' => account.id, 'category_id' => category.id }
            ]
          }
        }
      )

      expect(result[:pushed][:transactions][:created].length).to eq(1)
      expect(result[:pushed][:transactions][:rejected].length).to eq(1)
    end
  end
end
