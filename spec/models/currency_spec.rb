require 'rails_helper'

RSpec.describe Currency, type: :model do
  it 'has a valid factory' do
    expect(create :currency).to be_valid
  end

  describe '.associations' do
    it { is_expected.to have_many :accounts }
    it do
      is_expected.to have_many(:aggregated_transactions).
        dependent :destroy
    end
    it { is_expected.to have_many(:budgets).dependent :destroy }
  end

  describe '.validations' do
    context 'when valid' do
      subject { create :currency }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_uniqueness_of :name }
    end
  end
end
