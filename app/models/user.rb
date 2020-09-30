class User < ApplicationRecord
  has_many :aggregated_transactions, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :cash_flows, dependent: :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  before_destroy :cleanup_accounts

  def currencies
    Currency.where(id: accounts.pluck(:currency_id)).by_recently_used.distinct
  end

  private

  def cleanup_accounts
    accounts.deleted.each do |account|
      account.destroy(permanent_destroy: true)
    end
  end
end
