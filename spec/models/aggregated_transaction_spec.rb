require 'spec_helper'

describe AggregatedTransaction do
  it 'has a valid factory' do
    expect(create :aggregated_transaction).to be_valid
  end

  describe '.associations' do
    it { should belong_to :user }
    it { should belong_to :category }
    it { should belong_to :category_type }
  end

  describe '.validations' do
    context 'when valid' do
      subject { create :aggregated_transaction }
      it { should validate_presence_of :user }
      it { should validate_presence_of :category }
      it { should validate_presence_of :category_type_id }
      it { should validate_presence_of :amount }
      it { should validate_numericality_of :amount }
      it { should validate_presence_of :period_started_at }
      it { should validate_presence_of :period_ended_at }
    end
  end
end
