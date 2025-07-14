class RecurringCashFlow < ApplicationRecord
  belongs_to :user
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :user, :from_account, :to_account, :amount, :frequency_amount, :next_transfer_on, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.01 }
  validates :frequency_amount, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validate :ensure_next_transfer_on_is_in_the_future
  validate :ensure_ends_on_is_not_too_far_in_the_past
  validate :from_and_to_accounts_are_different

  enum :frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

  scope :upcoming, -> { order(:next_transfer_on) }
  scope :active, -> { where('ends_on IS NULL OR ends_on >= ?', Date.today) }
  scope :ended, -> { where('ends_on < ?', Date.today) }
  scope :due, -> { where('recurring_cash_flows.next_transfer_on <= ?', Date.today).active }

  def move_to_next_transfer
    duration_method = {
      'daily' => :days,
      'weekly' => :weeks,
      'monthly' => :months,
      'yearly' => :years
    }.fetch(frequency)

    new_next_transfer_on = frequency_amount.public_send(duration_method).since(next_transfer_on)

    update(next_transfer_on: new_next_transfer_on)
  end

  private

  def ensure_next_transfer_on_is_in_the_future
    if next_transfer_on.present? && next_transfer_on < Date.today
      errors.add(:next_transfer_on, :cannot_be_in_the_past)
    end
  end

  def ensure_ends_on_is_not_too_far_in_the_past
    if ends_on.present? && ends_on < 1.year.ago.to_date
      errors.add(:ends_on, 'cannot be more than a year in the past')
    end
  end

  def from_and_to_accounts_are_different
    if from_account_id == to_account_id
      errors.add(:to_account, 'cannot be the same as From Account')
    end
  end
end
