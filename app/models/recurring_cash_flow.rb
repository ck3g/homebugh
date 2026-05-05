class RecurringCashFlow < ApplicationRecord
  include Schedulable
  include SyncDeletionTrackable

  schedulable_date_column :next_transfer_on

  belongs_to :user
  belongs_to :from_account, class_name: 'Account'
  belongs_to :to_account, class_name: 'Account'

  validates :user, :from_account, :to_account, presence: true
  validate :from_and_to_accounts_are_different

  scope :upcoming, -> { order(:next_transfer_on) }
  scope :due, -> { where('recurring_cash_flows.next_transfer_on <= ?', Date.today).active }

  alias_method :move_to_next_transfer, :advance_schedule

  private

  def from_and_to_accounts_are_different
    if from_account_id == to_account_id
      errors.add(:to_account, 'cannot be the same as From Account')
    end
  end
end
