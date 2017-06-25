require 'rails_helper'

RSpec.describe BudgetDecorator do
  let(:decorator) { described_class.new budget }

  describe "#current_expenses" do
    subject { decorator.current_expenses }

    let(:budget) { double limit: 400, expenses: 200, currency: currency }
    let(:currency) { double unit: "", name: "EUR" }

    it { is_expected.to eq "200.00 / 400.00 EUR" }
  end
end
