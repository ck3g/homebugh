class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @statistics = Statistic.current_month_stats(current_user.id)
  end

  def archived
    @stats = Stats.new(current_user.aggregated_transactions).all
  end
end
