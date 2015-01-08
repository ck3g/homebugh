require 'rails_helper'

RSpec.describe AccountDecorator, type: :model do
  let(:decorator) { AccountDecorator.new account }
  describe '#amount' do
    subject { decorator.amount }

    let(:account) { mock_model Account, funds: '50.30', currency_unit: '$' }

    it "returns amount with currency unit" do
      is_expected.to eq '50.30 $'
    end
  end

  describe '#name' do
    subject { decorator.name }

    let(:account) { mock_model Account, name: 'Card', currency_unit: '$' }

    it "returns name with currency unit" do
      is_expected.to eq "Card [$]"
    end
  end

  describe '#unit' do
    subject { decorator.unit }

    context 'when currency unit is present' do
      let(:account) do
        mock_model Account, currency_name: 'USD', currency_unit: '$'
      end

      it "returns unit" do
        is_expected.to eq '$'
      end
    end

    context 'when currency unit is blank' do
      let(:account) do
        mock_model Account, currency_name: 'USD', currency_unit: ''
      end

      it "returns name" do
        is_expected.to eq 'USD'
      end
    end
  end
end
