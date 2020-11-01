require 'rails_helper'

RSpec.describe AuthSession, type: :model do
  it 'has a valid factory' do
    expect(create(:auth_session)).to be_valid
  end

  describe '.associations' do
    it { is_expected.to belong_to :user }
  end

  describe '.validations' do
    context 'when valid' do
      subject { build(:auth_session) }

      it { is_expected.to validate_presence_of(:user) }
      it { is_expected.to validate_presence_of(:token) }
      it { is_expected.to validate_presence_of(:expired_at) }
      it { is_expected.to validate_uniqueness_of(:token) }
    end
  end
end
