class StatisticsController < ApplicationController

  def index
    authorize! :index, :statistics

    @current_currency = current_currency

    # Get current month stats
    @current_month_stats = StatisticsService.current_month_stats(
      @current_currency.try(:id),
      current_user.id
    )

    # Get past months stats (last 24 months excluding current month)
    @past_months_stats = HistoricalStats.new(
      @current_currency,
      current_user.aggregated_transactions
    ).all.lazy.first(24)

    # Calculate 12-month totals
    twelve_month_totals = StatisticsService.twelve_month_totals(
      @current_currency,
      current_user,
      @current_month_stats,
      @past_months_stats
    )
    
    @twelve_month_income = twelve_month_totals[:income]
    @twelve_month_spending = twelve_month_totals[:spending]
    @twelve_month_net_balance = twelve_month_totals[:net_balance]
  end

  def archived
    authorize! :archived, :statistics
    @stats = HistoricalStats.new(
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
