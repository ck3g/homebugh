require 'rails_helper'

RSpec.describe BudgetDecorator do
  let(:decorator) { described_class.new budget }

  describe "#current_expenses" do
    subject { decorator.current_expenses }

    let(:budget) { double limit: 400, expenses: 200, currency: currency }
    let(:currency) { double unit: "", name: "EUR" }

    it { is_expected.to eq "200.00 / 400.00 EUR" }
  end

  describe "#expenses_color_class" do
    subject { decorator.expenses_color_class }

    let(:currency) { double unit: "", name: "EUR" }

    context "when current expenses less than 75% of the budget" do
      let(:budget) { double limit: 100, expenses: 20 }

      it { is_expected.to eq "success" }
    end

    context "when current expenses 100% or more" do
      let(:budget) { double limit: 100, expenses: 120 }

      it { is_expected.to eq "danger" }
    end

    context "when current expenses between 75% and 100%" do
      let(:budget) { double limit: 100, expenses: 80 }

      it { is_expected.to eq "warning" }
    end
  end
end
