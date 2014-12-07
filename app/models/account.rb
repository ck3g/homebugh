class Account < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_many :cash_flows, as: :from_account
  has_many :cash_flows, as: :to_account

  validates :name, :user_id, :currency, presence: true
  validates :name, uniqueness: {
    scope: [:user_id, :currency_id], case_sensitive: false }

  delegate :name, :unit, to: :currency, prefix: true

  def deposit(amount)
    amount ||= 0.0
    update_attribute :funds, funds + amount
  end

  def withdrawal(amount)
    amount ||= 0.0
    update_attribute :funds, funds - amount
  end
end
