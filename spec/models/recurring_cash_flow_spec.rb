require 'rails_helper'

RSpec.describe RecurringCashFlow, type: :model do
  it 'has a valid factory' do
    expect(create(:recurring_cash_flow)).to be_valid
  end

  describe '.associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:from_account).class_name('Account') }
    it { is_expected.to belong_to(:to_account).class_name('Account') }
  end

  describe '.validations' do
    context 'with valid attributes' do
      subject { create(:recurring_cash_flow) }

      it { is_expected.to validate_presence_of(:user) }
      it { is_expected.to validate_presence_of(:from_account) }
      it { is_expected.to validate_presence_of(:to_account) }

      it 'when from and to accounts are the same' do
        account = create(:account)
        rcf = build_stubbed(:recurring_cash_flow, from_account: account, to_account: account)
        expect(rcf).to be_invalid
        expect(rcf.errors.full_messages_for(:to_account)).to eq(["To Account cannot be the same as From Account"])
      end
    end
  end

  it_behaves_like 'schedulable', factory: :recurring_cash_flow, next_date_column: :next_transfer_on

  describe '.upcoming' do
    subject { described_class.upcoming }

    let!(:due_today) { create(:recurring_cash_flow, next_transfer_on: Date.today) }
    let!(:due_one_month) { create(:recurring_cash_flow, next_transfer_on: 1.month.from_now) }
    let!(:due_one_week) { create(:recurring_cash_flow, next_transfer_on: 1.week.from_now) }

    it 'orders by closest due date' do
      is_expected.to eq([due_today, due_one_week, due_one_month])
    end
  end

  describe '.due' do
    subject { described_class.due }

    let!(:due_yesterday) { create(:recurring_cash_flow, :due) }
    let!(:due_today) { create(:recurring_cash_flow, next_transfer_on: Date.today) }
    let!(:due_tomorrow) { create(:recurring_cash_flow, next_transfer_on: 1.day.from_now) }
    let!(:ended_yesterday) { create(:recurring_cash_flow, :due, ends_on: 1.day.ago.to_date) }

    it 'returns only due payments' do
      is_expected.to contain_exactly(due_yesterday, due_today)
    end
  end

  describe '#move_to_next_transfer' do
    it 'is an alias for advance_schedule' do
      rcf = create(:recurring_cash_flow, frequency_amount: 1, frequency: :monthly, next_transfer_on: Date.current)
      expect { rcf.move_to_next_transfer }.to change { rcf.next_transfer_on }.to(1.month.since(Date.current))
    end
  end
end
