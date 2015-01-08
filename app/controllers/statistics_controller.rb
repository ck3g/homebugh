class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @statistics = Statistic.current_month_stats(
      current_currency.id,
      current_user.id
    )
  end

  def archived
    @stats = Stats.new(
      current_currency,
      current_user.aggregated_transactions
    ).all.lazy.first(12)
  end

  private
  def current_currency
    name = params[:currency].presence ||
      current_user.currencies.first.try(:name)
    @currency ||= Currency.find_by!(name: name)
  end
end
