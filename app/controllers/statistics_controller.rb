class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :js

  def index
    @statistics = Kaminari.paginate_array(Statistic.stats_by_months(current_user.id)).page(params[:page]).per(2)
  end
end
