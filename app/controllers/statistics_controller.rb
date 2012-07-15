class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @statistics = Statistic.stats_by_months current_user.id
  end

  def show
    @statistic = Statistic.find(params[:id])
  end
end
