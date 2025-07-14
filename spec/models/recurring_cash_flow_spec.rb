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
      it { is_expected.to validate_presence_of(:amount) }
      it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0.01) }
      it { is_expected.to validate_presence_of(:frequency_amount) }
      it do
        is_expected.to validate_numericality_of(:frequency_amount)
          .is_greater_than_or_equal_to(1)
          .only_integer
      end

      it { is_expected.to validate_presence_of(:next_transfer_on) }

      it 'when next transfer on is in the future' do
        rcf = build_stubbed(:recurring_cash_flow, next_transfer_on: 1.day.from_now.to_date)
        expect(rcf).to be_valid
      end

      it 'when next transfer on is today' do
        rcf = build_stubbed(:recurring_cash_flow, next_transfer_on: Date.today)
        expect(rcf).to be_valid
      end

      it 'when next transfer on is in the past' do
        rcf = build_stubbed(:recurring_cash_flow, next_transfer_on: 1.day.ago.to_date)
        expect(rcf).to be_invalid
        expect(rcf.errors.full_messages_for(:next_transfer_on)).to eq(["Next Transfer cannot be in the past"])
      end

      it 'when ends on is more than a year in the past' do
        rcf = build_stubbed(:recurring_cash_flow, ends_on: 1.year.ago.to_date - 1.day)
        expect(rcf).to be_invalid
        expect(rcf.errors.full_messages_for(:ends_on)).to eq(["Ends On cannot be more than a year in the past"])
      end

      it 'when ends on is less than a year in the past' do
        rcf = build_stubbed(:recurring_cash_flow, ends_on: 1.year.ago.to_date + 1.day)
        expect(rcf).to be_valid
      end

      it 'when from and to accounts are the same' do
        account = create(:account)
        rcf = build_stubbed(:recurring_cash_flow, from_account: account, to_account: account)
        expect(rcf).to be_invalid
        expect(rcf.errors.full_messages_for(:to_account)).to eq(["To Account cannot be the same as From Account"])
      end
    end
  end

  it 'define enum for frequency' do
    is_expected.to define_enum_for(:frequency).with_values(daily: 0, weekly: 1, monthly: 2, yearly: 3)
  end

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

  describe '.active' do
    subject { described_class.active }

    let!(:active_cash_flow) { create(:recurring_cash_flow, ends_on: 1.day.from_now.to_date) }
    let!(:never_ends_cash_flow) { create(:recurring_cash_flow, ends_on: nil) }
    let!(:ended_cash_flow) { create(:recurring_cash_flow, ends_on: 1.day.ago.to_date) }

    it 'returns only active cash flows' do
      is_expected.to contain_exactly(active_cash_flow, never_ends_cash_flow)
    end
  end

  describe '.ended' do
    subject { described_class.ended }

    let!(:active_cash_flow) { create(:recurring_cash_flow, ends_on: 1.day.from_now.to_date) }
    let!(:never_ends_cash_flow) { create(:recurring_cash_flow, ends_on: nil) }
    let!(:ended_cash_flow) { create(:recurring_cash_flow, ends_on: 1.day.ago.to_date) }

    it 'returns only ended cash flows' do
      is_expected.to contain_exactly(ended_cash_flow)
    end
  end

  describe '#move_to_next_transfer' do
    subject(:move_to_next_transfer) { rcf.move_to_next_transfer }

    let(:initial_transfer_on) { Date.current }

    context 'when a frequency is every 5th day' do
      let(:rcf) { create(:recurring_cash_flow, frequency_amount: 5, frequency: :daily, next_transfer_on: initial_transfer_on) }

      it 'moves next_transfer_on 5 days ahead' do
        expect { move_to_next_transfer }.to change { rcf.next_transfer_on }.to(5.days.since(initial_transfer_on))
      end
    end

    context 'when a frequency is every 2 weeks' do
      let(:rcf) { create(:recurring_cash_flow, frequency_amount: 2, frequency: :weekly, next_transfer_on: initial_transfer_on) }

      it 'moves next_transfer_on 2 weeks ahead' do
        expect { move_to_next_transfer }.to change { rcf.next_transfer_on }.to(2.weeks.since(initial_transfer_on))
      end
    end

    context 'when a frequency is every month' do
      let(:rcf) { create(:recurring_cash_flow, frequency_amount: 1, frequency: :monthly, next_transfer_on: initial_transfer_on) }

      it 'moves next_transfer_on 1 month ahead' do
        expect { move_to_next_transfer }.to change { rcf.next_transfer_on }.to(1.month.since(initial_transfer_on))
      end
    end

    context 'when a frequency is every year' do
      let(:rcf) { create(:recurring_cash_flow, frequency_amount: 1, frequency: :yearly, next_transfer_on: initial_transfer_on) }

      it 'moves next_transfer_on 1 year ahead' do
        expect { move_to_next_transfer }.to change { rcf.next_transfer_on }.to(1.year.since(initial_transfer_on))
      end
    end
  end
end
