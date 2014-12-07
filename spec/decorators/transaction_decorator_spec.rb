require 'rails_helper'

RSpec.describe TransactionDecorator do
  let(:decorator) { TransactionDecorator.new transaction }

  describe '#amount' do
    subject { decorator.amount }

    let(:account) { double decorate: double(unit: '$') }

    context 'when type is income' do
      let(:transaction) do
        mock_model Transaction, account: account, income?: true,
          summ: 503
      end

      it { is_expected.to eq "503.00 $" }
    end

    context 'when type is spending' do
      let(:transaction) do
        mock_model Transaction, account: account, income?: false,
          summ: 503
      end

      it { is_expected.to eq "-503.00 $" }
    end
  end
end
