require 'rails_helper'

RSpec.describe Api::Sync::PullProcessor do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency) }
  let(:category) { create(:spending_category, user: user) }

  subject { described_class.new(user) }

  describe '#process' do
    context 'incremental pull (with last_synced_at)' do
      it 'returns records updated since last_synced_at' do
        old_txn = create(:transaction, user: user, account: account, category: category)
        old_txn.update_column(:updated_at, 2.days.ago)

        new_txn = create(:transaction, user: user, account: account, category: category)
        new_txn.update_column(:updated_at, 1.hour.ago)

        result = subject.process(last_synced_at: 1.day.ago.iso8601)

        txn_ids = result[:transactions].map { |t| t[:id] }
        expect(txn_ids).to include(new_txn.id)
        expect(txn_ids).not_to include(old_txn.id)
      end

      it 'returns records from all syncable resource types' do
        create(:account, user: user, currency: currency)
        create(:category, user: user)
        create(:transaction, user: user, account: account, category: category)

        result = subject.process(last_synced_at: 1.day.ago.iso8601)

        expect(result).to have_key(:accounts)
        expect(result).to have_key(:categories)
        expect(result).to have_key(:transactions)
        expect(result).to have_key(:cash_flows)
        expect(result).to have_key(:budgets)
        expect(result).to have_key(:recurring_payments)
        expect(result).to have_key(:recurring_cash_flows)
      end

      it 'does not return other users records' do
        create(:transaction, user: other_user)
        create(:transaction, user: user, account: account, category: category)

        result = subject.process(last_synced_at: 1.day.ago.iso8601)

        txn_user_ids = result[:transactions].map { |t| Transaction.find(t[:id]).user_id }.uniq
        expect(txn_user_ids).to eq([user.id])
      end

      it 'includes deletions since last_synced_at' do
        SyncDeletion.create!(resource_type: 'Transaction', resource_id: 999, user_id: user.id, deleted_at: 1.hour.ago)
        SyncDeletion.create!(resource_type: 'Transaction', resource_id: 888, user_id: user.id, deleted_at: 2.days.ago)

        result = subject.process(last_synced_at: 1.day.ago.iso8601)

        deletions = result[:deletions]
        expect(deletions.length).to eq(1)
        expect(deletions.first[:resource_id]).to eq(999)
      end

      it 'does not include other users deletions' do
        SyncDeletion.create!(resource_type: 'Transaction', resource_id: 777, user_id: other_user.id, deleted_at: 1.hour.ago)

        result = subject.process(last_synced_at: 1.day.ago.iso8601)

        expect(result[:deletions]).to be_empty
      end
    end

    context 'full pull (null last_synced_at)' do
      it 'returns all records when last_synced_at is nil' do
        txn1 = create(:transaction, user: user, account: account, category: category)
        txn1.update_column(:updated_at, 1.year.ago)
        txn2 = create(:transaction, user: user, account: account, category: category)

        result = subject.process(last_synced_at: nil)

        txn_ids = result[:transactions].map { |t| t[:id] }
        expect(txn_ids).to include(txn1.id, txn2.id)
      end
    end

    context 'excluding pushed records' do
      it 'excludes recently pushed record ids' do
        txn1 = create(:transaction, user: user, account: account, category: category)
        txn2 = create(:transaction, user: user, account: account, category: category)

        result = subject.process(
          last_synced_at: 1.day.ago.iso8601,
          exclude_ids: { 'Transaction' => [txn1.id] }
        )

        txn_ids = result[:transactions].map { |t| t[:id] }
        expect(txn_ids).not_to include(txn1.id)
        expect(txn_ids).to include(txn2.id)
      end
    end

    context 'pagination' do
      it 'caps results and returns has_more and cursor' do
        # Create more records than the cap
        12.times { create(:transaction, user: user, account: account, category: category) }

        result = subject.process(last_synced_at: 1.day.ago.iso8601, pull_limit: 5)

        total_records = result.except(:deletions, :has_more, :cursor).values.flatten.length
        expect(total_records).to be <= 5
        expect(result[:has_more]).to be true
        expect(result[:cursor]).to be_present
      end

      it 'returns has_more false when all records fit' do
        create(:transaction, user: user, account: account, category: category)

        result = subject.process(last_synced_at: 1.day.ago.iso8601, pull_limit: 200)

        expect(result[:has_more]).to be false
      end
    end
  end
end
