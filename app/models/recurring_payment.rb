class RecurringPayment < ApplicationRecord
  include Categorizable

  belongs_to :user
  belongs_to :account

  validates :title, :user, :category, :account, :next_payment_on, presence: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
  validates :frequency_amount, presence: true, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validate :ensure_next_payment_on_is_in_the_future
  validate :ensure_ends_on_is_not_too_far_in_the_past

  enum :frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

  delegate :name, to: :category, prefix: true
  delegate :name, to: :account, prefix: true

  scope :upcoming, -> { order(:next_payment_on) }
  scope :due, -> { where('recurring_payments.next_payment_on <= ?', Date.today).active }
  scope :active, -> { where('ends_on IS NULL OR ends_on >= ?', Date.today) }
  scope :ended, -> { where('ends_on < ?', Date.today) }

  def move_to_next_payment
    duration_method = {
      'daily' => :days,
      'weekly' => :weeks,
      'monthly' => :months,
      'yearly' => :years
    }.fetch(frequency)

    new_next_payment_on = frequency_amount.public_send(duration_method).since(next_payment_on)

    update(next_payment_on: new_next_payment_on)
  end

  private

  def ensure_next_payment_on_is_in_the_future
    if next_payment_on.present? && next_payment_on < Date.today
      errors.add(:next_payment_on, :cannot_be_in_the_past)
    end
  end

  def ensure_ends_on_is_not_too_far_in_the_past
    if ends_on.present? && ends_on < 1.year.ago.to_date
      errors.add(:ends_on, 'cannot be more than a year in the past')
    end
  end
end
