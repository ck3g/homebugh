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
      it { is_expected.to validate_presence_of(:amount) }
      it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0.01) }
      it { is_expected.to validate_presence_of(:frequency_amount) }
      it do
        is_expected.to validate_numericality_of(:frequency_amount)
          .is_greater_than_or_equal_to(1)
          .only_integer
      end

      it { is_expected.to validate_presence_of(:next_payment_on) }

      it 'when next payment on is in the future' do
        rp = build_stubbed(:recurring_payment, next_payment_on: 1.day.from_now.to_date)
        expect(rp).to be_valid
      end

      it 'when next payment on is today' do
        rp = build_stubbed(:recurring_payment, next_payment_on: Date.today)
        expect(rp).to be_valid
      end

      it 'when next payment on is in the past' do
        rp = build_stubbed(:recurring_payment, next_payment_on: 1.day.ago.to_date)
        expect(rp).to be_invalid
        expect(rp.errors.full_messages_for(:next_payment_on)).to eq(["Next payment cannot be in the past"])
      end
    end
  end

  it 'define enum for frequency' do
    is_expected.to define_enum_for(:frequency).with_values(daily: 0, weekly: 1, monthly: 2, yearly: 3)
  end

  describe '.upcoming' do
    subject { described_class.upcoming }

    let!(:due_today) { create(:recurring_payment, next_payment_on: Date.today) }
    let!(:due_one_month) { create(:recurring_payment, next_payment_on: 1.month.from_now) }
    let!(:due_one_week) { create(:recurring_payment, next_payment_on: 1.week.from_now) }

    it 'orders by closest due date' do
      is_expected.to eq([due_today, due_one_week, due_one_month])
    end
  end

  describe '#income?' do
    subject { build_stubbed(:recurring_payment, category: category ) }

    context 'when recurring payment has income category' do
      let(:category) { build_stubbed(:income_category) }

      it { is_expected.to be_income}
    end

    context 'when recurring payment has spending category' do
      let(:category) { build_stubbed(:spending_category) }

      it { is_expected.not_to be_income }
    end
  end
end
