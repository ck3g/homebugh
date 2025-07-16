class StatisticsController < ApplicationController

  def index
    authorize! :index, :statistics

    # Get current month stats
    @current_month_stats = Statistic.current_month_stats(
      current_currency.try(:id),
      current_user.id
    )

    # Get past months stats (last 24 months excluding current month)
    @past_months_stats = Stats.new(
      current_currency,
      current_user.aggregated_transactions
    ).all.lazy.first(24)
  end

  def archived
    authorize! :archived, :statistics
    @stats = Stats.new(
      current_currency,
      current_user.aggregated_transactions
    ).all.lazy.first(12)
  end

  private
  def current_currency
    name = params[:currency].presence ||
      current_user.currencies.first.try(:name)
    @currency ||= Currency.find_by(name: name)
  end
end
