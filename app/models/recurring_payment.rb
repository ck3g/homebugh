class RecurringPayment < ApplicationRecord
  include Categorizable
  include Schedulable
  include SyncDeletionTrackable

  schedulable_date_column :next_payment_on

  belongs_to :user
  belongs_to :account

  validates :title, :user, :category, :account, presence: true

  delegate :name, to: :category, prefix: true
  delegate :name, to: :account, prefix: true

  scope :upcoming, -> { order(:next_payment_on) }
  scope :due, -> { where('recurring_payments.next_payment_on <= ?', Date.today).active }

  alias_method :move_to_next_payment, :advance_schedule
end
