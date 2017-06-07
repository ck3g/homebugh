class Account < ActiveRecord::Base
  include AASM
  include Orderable

  belongs_to :user
  belongs_to :currency, touch: true
  has_many :transactions, dependent: :nullify
  has_many :cash_flows, as: :from_account
  has_many :cash_flows, as: :to_account

  validates :name, :user_id, :currency, presence: true
  validates :name, uniqueness: {
    scope: [:user_id, :currency_id], case_sensitive: false }

  delegate :name, :unit, to: :currency, prefix: true

  aasm column: :status do
    state :active, initial: true
    state :deleted

    event :mark_as_deleted do
      transitions to: :deleted
    end
  end

  def deposit(amount)
    amount ||= 0.0
    update_attribute :funds, funds + amount
  end

  def withdrawal(amount)
    amount ||= 0.0
    update_attribute :funds, funds - amount
  end

  def destroy
    mark_as_deleted! if funds.zero?
  end
end
