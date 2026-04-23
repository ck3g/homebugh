module Schedulable
  extend ActiveSupport::Concern

  included do
    enum :frequency, { daily: 0, weekly: 1, monthly: 2, yearly: 3 }

    validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0.01 }
    validates :frequency_amount, presence: true,
              numericality: { greater_than_or_equal_to: 1, only_integer: true }
    validate :ensure_next_date_is_not_in_the_past
    validate :ensure_ends_on_is_not_too_far_in_the_past

    scope :active, -> { where('ends_on IS NULL OR ends_on >= ?', Date.today) }
    scope :ended, -> { where('ends_on < ?', Date.today) }
  end

  class_methods do
    def schedulable_date_column(column)
      @schedulable_date_column = column

      validates column, presence: true
    end

    def next_date_column
      @schedulable_date_column
    end
  end

  def advance_schedule
    column = self.class.next_date_column
    current_date = send(column)

    duration_method = {
      'daily' => :days,
      'weekly' => :weeks,
      'monthly' => :months,
      'yearly' => :years
    }.fetch(frequency)

    new_date = frequency_amount.public_send(duration_method).since(current_date)
    update(column => new_date)
  end

  private

  def ensure_next_date_is_not_in_the_past
    column = self.class.next_date_column
    value = send(column)

    if value.present? && value < Date.today
      errors.add(column, :cannot_be_in_the_past)
    end
  end

  def ensure_ends_on_is_not_too_far_in_the_past
    if ends_on.present? && ends_on < 1.year.ago.to_date
      errors.add(:ends_on, 'cannot be more than a year in the past')
    end
  end
end
