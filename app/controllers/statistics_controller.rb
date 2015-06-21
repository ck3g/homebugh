class StatisticsController < ApplicationController

  def index
    authorize! :index, :statistics
    @statistics = Statistic.current_month_stats(
      current_currency.try(:id),
      current_user.id
    )
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
