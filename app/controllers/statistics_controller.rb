class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  caches_action :index

  def index
    @statistics = Statistic.stats_by_months current_user.id
  end
end
