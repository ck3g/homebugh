require 'rails_helper'

RSpec.describe FundsTransferService, type: :model do
  describe '#transfer' do
    let!(:source) { create :account, funds: 100 }
    let!(:destination) { create :account, funds: 50 }

    subject do
      FundsTransferService.new(source, destination).transfer(30, 15)
    end

    it "withdraw amount from source account" do
      expect {
        subject
        source.reload
      }.to change { source.funds }.by -30
    end

    it "deposit amount to destination account" do
      expect {
        subject
        destination
      }.to change { destination.funds }.by 15
    end
  end
end
