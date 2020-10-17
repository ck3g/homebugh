require 'rails_helper'

RSpec.describe TotalAmount do
  describe '#of' do
    subject { TotalAmount.of(user).transform_values(&:to_f) }

    let(:user) { create(:user) }
    let(:usd) { create(:currency, name: 'USD') }
    let(:eur) { create(:currency, name: 'EUR') }
    let(:mdl) { create(:currency, name: 'MDL') }
    let!(:eur_account1) { create(:account, user: user, currency: eur, funds: 200.0) }
    let!(:eur_account2) { create(:account, user: user, currency: eur, funds: 303.0) }
    let!(:mdl_account) { create(:account, user: user, currency: mdl, funds: 403.0) }
    let!(:inactive_account) { create(:account, :deleted, user: user, currency: eur, funds: 100.0) }
    let!(:hidden__account) { create(:account, :hidden, user: user, currency: usd, funds: 200.0) }
    let!(:other_user_account) { create(:account, currency: eur, funds: 1000) }

    it "calculates total amount grouped by currency" do
      is_expected.to eq('EUR' => 503.0, 'MDL' => 403.0)
    end
  end
end
