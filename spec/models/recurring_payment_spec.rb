require 'rails_helper'

RSpec.describe RecurringPayment, type: :model do
  it 'has a valid factory' do
    expect(create(:recurring_payment)).to be_valid
  end

  describe '.associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category) }
    it { is_expected.to belong_to(:account) }
  end

  describe '.validations' do
    context 'with valid attributes' do
      subject { create(:recurring_payment) }

      it { is_expected.to validate_presence_of(:title) }
      it { is_expected.to validate_presence_of(:user) }
      it { is_expected.to validate_presence_of(:category) }
      it { is_expected.to validate_presence_of(:account) }
    end
  end

  it_behaves_like 'schedulable', factory: :recurring_payment, next_date_column: :next_payment_on

  describe '.upcoming' do
    subject { described_class.upcoming }

    let!(:due_today) { create(:recurring_payment, next_payment_on: Date.today) }
    let!(:due_one_month) { create(:recurring_payment, next_payment_on: 1.month.from_now) }
    let!(:due_one_week) { create(:recurring_payment, next_payment_on: 1.week.from_now) }

    it 'orders by closest due date' do
      is_expected.to eq([due_today, due_one_week, due_one_month])
    end
  end

  describe '.due' do
    subject { described_class.due }

    let!(:due_yesterday) { create(:recurring_payment, :due) }
    let!(:due_today) { create(:recurring_payment, next_payment_on: Date.today) }
    let!(:due_tomorrow) { create(:recurring_payment, next_payment_on: 1.day.from_now) }
    let!(:ended_yesterday) { create(:recurring_payment, :due, ends_on: 1.day.ago.to_date) }

    it 'returns only due payments' do
      is_expected.to contain_exactly(due_yesterday, due_today)
    end
  end

  describe '#income?' do
    subject { build_stubbed(:recurring_payment, category: category) }

    context 'when recurring payment has income category' do
      let(:category) { build_stubbed(:income_category) }

      it { is_expected.to be_income }
    end

    context 'when recurring payment has spending category' do
      let(:category) { build_stubbed(:spending_category) }

      it { is_expected.not_to be_income }
    end
  end

  describe '#move_to_next_payment' do
    it 'is an alias for advance_schedule' do
      rp = create(:recurring_payment, frequency_amount: 1, frequency: :monthly, next_payment_on: Date.current)
      expect { rp.move_to_next_payment }.to change { rp.next_payment_on }.to(1.month.since(Date.current))
    end
  end
end
