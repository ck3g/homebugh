require 'rails_helper'

RSpec.describe Currency, type: :model do
  it 'has a valid factory' do
    expect(create :currency).to be_valid
  end

  describe '.validations' do
    context 'when valid' do
      subject { create :currency }
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_uniqueness_of :name }
    end
  end
end
