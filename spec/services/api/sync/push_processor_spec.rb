require 'rails_helper'

RSpec.describe Api::Sync::PushProcessor do
  let(:user) { create(:user) }
  let(:currency) { create(:currency) }
  let(:account) { create(:account, user: user, currency: currency, funds: 1000.00) }
  let(:category) { create(:spending_category, user: user) }
  let(:income_category) { create(:income_category, user: user) }

  subject { described_class.new(user) }

  describe '#process' do
    context 'creates' do
      it 'creates a new category and returns server_id' do
        CategoryType.find_or_create_by!(id: CategoryType.expense, name: 'spending')

        changes = {
          'categories' => {
            'created' => [
              { 'client_uuid' => 'ios-1', 'name' => 'Gym', 'category_type_id' => CategoryType.expense }
            ]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:created].length).to eq(1)
        created = result[:categories][:created].first
        expect(created[:client_uuid]).to eq('ios-1')
        expect(created[:server_id]).to be_present
        expect(created[:status]).to eq('ok')
        expect(Category.find(created[:server_id]).name).to eq('Gym')
      end

      it 'creates a transaction with amount mapped to summ' do
        changes = {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'ios-t1', 'amount' => 50.0, 'account_id' => account.id, 'category_id' => category.id, 'comment' => 'Lunch' }
            ]
          }
        }

        result = subject.process(changes)

        created = result[:transactions][:created].first
        expect(created[:status]).to eq('ok')
        transaction = Transaction.find(created[:server_id])
        expect(transaction.summ).to eq(50.0)
        expect(transaction.comment).to eq('Lunch')
      end

      it 'applies AccountBalance on transaction create' do
        changes = {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'ios-t2', 'amount' => 75.0, 'account_id' => account.id, 'category_id' => category.id }
            ]
          }
        }

        subject.process(changes)

        expect(account.reload.funds).to eq(925.0)
      end

      it 'returns existing server_id for duplicate client_uuid' do
        existing = create(:transaction, user: user, account: account, category: category, client_uuid: 'ios-dup')

        changes = {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'ios-dup', 'amount' => 99.0, 'account_id' => account.id, 'category_id' => category.id }
            ]
          }
        }

        result = subject.process(changes)

        created = result[:transactions][:created].first
        expect(created[:server_id]).to eq(existing.id)
        expect(created[:status]).to eq('ok')
      end

      it 'does not create duplicate for existing client_uuid' do
        create(:transaction, user: user, account: account, category: category, client_uuid: 'ios-dup2')

        changes = {
          'transactions' => {
            'created' => [
              { 'client_uuid' => 'ios-dup2', 'amount' => 99.0, 'account_id' => account.id, 'category_id' => category.id }
            ]
          }
        }

        expect {
          subject.process(changes)
        }.not_to change(Transaction, :count)
      end

      it 'reports validation errors as rejections' do
        changes = {
          'categories' => {
            'created' => [
              { 'client_uuid' => 'ios-bad', 'name' => '', 'category_type_id' => CategoryType.expense }
            ]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:rejected].length).to eq(1)
        rejected = result[:categories][:rejected].first
        expect(rejected[:client_uuid]).to eq('ios-bad')
        expect(rejected[:operation]).to eq('create')
        expect(rejected[:reason]).to be_present
      end
    end

    context 'updates' do
      it 'updates a record when iOS timestamp is newer' do
        cat = create(:category, user: user, name: 'Old')
        cat.update_column(:updated_at, 2.days.ago)

        changes = {
          'categories' => {
            'updated' => [
              { 'id' => cat.id, 'name' => 'New', 'updated_at' => 1.hour.ago.iso8601 }
            ]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:updated].first[:status]).to eq('ok')
        expect(cat.reload.name).to eq('New')
      end

      it 'skips update when server timestamp is newer' do
        cat = create(:category, user: user, name: 'Server Version')
        cat.update_column(:updated_at, 1.hour.ago)

        changes = {
          'categories' => {
            'updated' => [
              { 'id' => cat.id, 'name' => 'iOS Version', 'updated_at' => 2.days.ago.iso8601 }
            ]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:updated].first[:status]).to eq('skipped')
        expect(cat.reload.name).to eq('Server Version')
      end

      it 'updates transaction comment' do
        txn = create(:transaction, user: user, account: account, category: category, comment: 'Old')
        txn.update_column(:updated_at, 2.days.ago)

        changes = {
          'transactions' => {
            'updated' => [
              { 'id' => txn.id, 'comment' => 'New comment', 'updated_at' => 1.hour.ago.iso8601 }
            ]
          }
        }

        result = subject.process(changes)

        expect(result[:transactions][:updated].first[:status]).to eq('ok')
        expect(txn.reload.comment).to eq('New comment')
      end
    end

    context 'deletes' do
      it 'deletes a transaction and reverses balance' do
        txn = create(:transaction, user: user, account: account, category: category, summ: 50.0)
        balance_after = account.reload.funds

        changes = {
          'transactions' => {
            'deleted' => [{ 'id' => txn.id }]
          }
        }

        result = subject.process(changes)

        expect(result[:transactions][:deleted].first[:status]).to eq('ok')
        expect { txn.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(account.reload.funds).to eq(balance_after + 50.0)
      end

      it 'soft-deletes a category' do
        cat = create(:category, user: user)

        changes = {
          'categories' => {
            'deleted' => [{ 'id' => cat.id }]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:deleted].first[:status]).to eq('ok')
        expect(cat.reload.status).to eq('deleted')
      end

      it 'reports rejection when account has non-zero balance' do
        funded_account = create(:account, user: user, currency: currency, funds: 500.0)

        changes = {
          'accounts' => {
            'deleted' => [{ 'id' => funded_account.id }]
          }
        }

        result = subject.process(changes)

        expect(result[:accounts][:rejected].length).to eq(1)
        rejected = result[:accounts][:rejected].first
        expect(rejected[:id]).to eq(funded_account.id)
        expect(rejected[:operation]).to eq('delete')
        expect(rejected[:reason]).to be_present
        expect(funded_account.reload.status).to eq('active')
      end
    end

    context 'with multiple resource types' do
      it 'processes all resource types and returns results' do
        changes = {
          'categories' => {
            'created' => [{ 'client_uuid' => 'ios-c1', 'name' => 'New Cat', 'category_type_id' => CategoryType.expense }]
          },
          'transactions' => {
            'created' => [{ 'client_uuid' => 'ios-t1', 'amount' => 25.0, 'account_id' => account.id, 'category_id' => category.id }]
          }
        }

        result = subject.process(changes)

        expect(result[:categories][:created].length).to eq(1)
        expect(result[:transactions][:created].length).to eq(1)
      end
    end

    it 'returns collected pushed record ids' do
      changes = {
        'transactions' => {
          'created' => [{ 'client_uuid' => 'ios-collect', 'amount' => 10.0, 'account_id' => account.id, 'category_id' => category.id }]
        }
      }

      subject.process(changes)

      expect(subject.pushed_record_ids).to have_key('Transaction')
      expect(subject.pushed_record_ids['Transaction']).to include(Transaction.last.id)
    end
  end
end
