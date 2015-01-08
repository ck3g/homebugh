class ArchiveTransactionsService
  attr_reader :user, :period_started_at, :period_ended_at

  def initialize(user, archive_date)
    @user = user
    @period_started_at = archive_date.beginning_of_month
    @period_ended_at = archive_date.end_of_month
  end

  def archive
    AggregatedTransaction.transaction do
      delete_aggregations_for_current_period

      user_transactions_for_period.find_each do |t|
        at = user.aggregated_transactions.where(
          period_started_at: period_started_at,
          period_ended_at: period_ended_at,
          category_id: t.category_id,
          category_type_id: t.category_type_id,
          currency_id: t.account_currency_id
        ).first_or_initialize
        at.amount = at.amount.to_f + t.summ
        at.save
      end
    end
  end

  private
  def user_transactions_for_period
    user.transactions.where(created_at: period_started_at..period_ended_at)
  end

  def delete_aggregations_for_current_period
    user.aggregated_transactions.where(
      period_started_at: period_started_at,
      period_ended_at: period_ended_at
    ).delete_all
  end
end
