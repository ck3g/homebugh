require 'rails_helper'

describe User, type: :model do
  it 'has a valid factory' do
    expect(create :user).to be_valid
  end

  describe '.associations' do
    it { is_expected.to have_many(:aggregated_transactions).dependent :destroy }
    it { is_expected.to have_many(:accounts).dependent :destroy }
    it { is_expected.to have_many(:categories).dependent :destroy }
    it { is_expected.to have_many(:transactions).dependent :destroy }
    it { is_expected.to have_many(:cash_flows).dependent :destroy }
  end
end
