require 'rails_helper'

describe AggregatedTransaction do
  it 'has a valid factory' do
    expect(create :aggregated_transaction).to be_valid
  end

  describe '.associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :category }
    it { is_expected.to belong_to :category_type }
  end

  describe '.validations' do
    context 'when valid' do
      subject { create :aggregated_transaction }
      it { is_expected.to validate_presence_of :user }
      it { is_expected.to validate_presence_of :category }
      it { is_expected.to validate_presence_of :category_type_id }
      it { is_expected.to validate_presence_of :amount }
      it { is_expected.to validate_numericality_of :amount }
      it { is_expected.to validate_presence_of :period_started_at }
      it { is_expected.to validate_presence_of :period_ended_at }
    end
  end
end
