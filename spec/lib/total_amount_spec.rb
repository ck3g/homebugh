require 'total_amount'

describe TotalAmount do
  describe '#of' do
    let(:account1) { double 'Account', funds: 200.0 }
    let(:account2) { double 'Account', funds: 303.0 }
    let(:user) { double 'User', accounts: [account1, account2] }

    subject { TotalAmount.of user }
    it { should eq 503.0 }
  end
end
