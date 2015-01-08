require 'total_amount'

RSpec.describe TotalAmount do
  describe '#of' do
    let(:decorator1) { double unit: '$' }
    let(:decorator2) { double unit: 'MDL' }
    let(:account1) { double 'Account', funds: 200.0, decorate: decorator1 }
    let(:account2) { double 'Account', funds: 303.0, decorate: decorator1 }
    let(:account3) { double 'Account', funds: 403.0, decorate: decorator2 }
    let(:user) { double 'User', accounts: [account1, account2, account3] }

    subject { TotalAmount.of user }
    it "calculates amount grouped by currency" do
      is_expected.to eq({ '$' => 503.0, 'MDL' => 403.0 })
    end
  end
end
