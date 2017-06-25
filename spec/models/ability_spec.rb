require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  context 'when user is guest' do
    subject { Ability.new nil }

    it { is_expected.not_to be_able_to :all, :all }
  end

  context 'when user is signed in' do
    let!(:user) { create :user }
    let!(:user_transaction) { create :transaction, user: user }
    let!(:other_transaction) { create :transaction }
    let!(:user_category) { create :category, user: user }
    let!(:other_category) { create :category }
    let!(:user_account) { create :account, user: user }
    let!(:other_account) { create :account }
    let!(:user_cash_flow) { create :cash_flow, user: user }
    let!(:other_cash_flow) { create :cash_flow }
    let!(:user_budget) { create :budget, user: user }
    let!(:other_budget) { create :budget }

    subject { Ability.new user }

    it { is_expected.to be_able_to :index, :statistics }
    it { is_expected.to be_able_to :archived, :statistics }

    it { is_expected.to be_able_to :create, Transaction }
    it { is_expected.to be_able_to :read, user_transaction }
    it { is_expected.to be_able_to :manage, user_transaction }
    it { is_expected.not_to be_able_to :manage, other_transaction }
    it { is_expected.not_to be_able_to :read, other_transaction }

    it { is_expected.to be_able_to :create, Category }
    it { is_expected.to be_able_to :read, user_category }
    it { is_expected.to be_able_to :manage, user_category }
    it { is_expected.not_to be_able_to :manage, other_category }
    it { is_expected.not_to be_able_to :read, other_category }

    it { is_expected.to be_able_to :create, Account }
    it { is_expected.to be_able_to :read, user_account }
    it { is_expected.to be_able_to :manage, user_account }
    it { is_expected.not_to be_able_to :manage, other_account }
    it { is_expected.not_to be_able_to :read, other_account }

    it { is_expected.to be_able_to :create, CashFlow }
    it { is_expected.to be_able_to :read, user_cash_flow }
    it { is_expected.to be_able_to :manage, user_cash_flow }
    it { is_expected.not_to be_able_to :manage, other_cash_flow }
    it { is_expected.not_to be_able_to :read, other_cash_flow }

    it { is_expected.to be_able_to :create, Budget }
    it { is_expected.to be_able_to :read, user_budget }
    it { is_expected.to be_able_to :manage, user_budget }
    it { is_expected.not_to be_able_to :manage, other_budget }
    it { is_expected.not_to be_able_to :read, other_budget }
  end
end
