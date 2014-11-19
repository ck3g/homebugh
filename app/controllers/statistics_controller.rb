class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @statistics = Kaminari.paginate_array(Statistic.stats_by_months(current_user.id)).page(params[:page]).per(5)
  end

  def chart
    @stats = Statistic.stats_by_months(current_user.id).take(12).reverse.map do |stat|
      { title: stat[:title][5..-1], income: stat[:income], spending: stat[:spending] }
    end
  end
end
