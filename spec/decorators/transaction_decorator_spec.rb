require 'rails_helper'

RSpec.describe TransactionDecorator do
  let(:decorator) { TransactionDecorator.new transaction }

  describe '#amount' do
    subject { decorator.amount }

    let(:account) { double decorate: double(unit: '$') }
    let(:transaction) { mock_model Transaction, account: account, summ: 503 }

    it { is_expected.to eq "503.00 $" }
  end
end
