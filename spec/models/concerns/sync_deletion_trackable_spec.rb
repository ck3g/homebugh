require 'rails_helper'

RSpec.describe SyncDeletionTrackable do
  let(:user) { create(:user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency) }
  let(:category) { create(:spending_category, user: user) }

  describe 'after_destroy callback' do
    it 'records a deletion for a transaction' do
      transaction = create(:transaction, user: user, account: account, category: category)

      expect {
        transaction.destroy
      }.to change(SyncDeletion, :count).by(1)

      deletion = SyncDeletion.last
      expect(deletion.resource_type).to eq('Transaction')
      expect(deletion.resource_id).to eq(transaction.id)
      expect(deletion.user_id).to eq(user.id)
      expect(deletion.deleted_at).to be_within(1.second).of(Time.current)
    end

    it 'records a deletion for a cash flow' do
      to_account = create(:account, user: user, currency: currency)
      cash_flow = create(:cash_flow, user: user, from_account: account, to_account: to_account)

      expect {
        cash_flow.destroy
      }.to change(SyncDeletion, :count).by(1)

      deletion = SyncDeletion.last
      expect(deletion.resource_type).to eq('CashFlow')
      expect(deletion.resource_id).to eq(cash_flow.id)
    end

    it 'records a deletion for a budget' do
      budget = create(:budget, user: user, category: category, currency: currency)

      expect {
        budget.destroy
      }.to change(SyncDeletion, :count).by(1)

      deletion = SyncDeletion.last
      expect(deletion.resource_type).to eq('Budget')
    end

    it 'records a deletion for a recurring payment' do
      rp = create(:recurring_payment, user: user, account: account, category: category)

      expect {
        rp.destroy
      }.to change(SyncDeletion, :count).by(1)

      deletion = SyncDeletion.last
      expect(deletion.resource_type).to eq('RecurringPayment')
    end

    it 'records a deletion for a recurring cash flow' do
      to_account = create(:account, user: user, currency: currency)
      rcf = create(:recurring_cash_flow, user: user, from_account: account, to_account: to_account)

      expect {
        rcf.destroy
      }.to change(SyncDeletion, :count).by(1)

      deletion = SyncDeletion.last
      expect(deletion.resource_type).to eq('RecurringCashFlow')
    end

    it 'does not record a deletion for soft-deleted accounts' do
      zero_account = create(:account, user: user, currency: currency, funds: 0)

      expect {
        zero_account.destroy
      }.not_to change(SyncDeletion, :count)
    end

    it 'does not record a deletion for soft-deleted categories' do
      standalone_category = create(:category, user: user)

      expect {
        standalone_category.destroy
      }.not_to change(SyncDeletion, :count)
    end
  end
end
