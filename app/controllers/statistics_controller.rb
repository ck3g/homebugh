class StatisticsController < ApplicationController
  before_filter :authenticate_user!

  # GET /statistics
  # GET /statistics.xml
  def index
    @statistics = Statistic.stats_by_months current_user.id

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @statistics }
    end
  end

  # GET /statistics/1
  # GET /statistics/1.xml
  def show
    @statistic = Statistic.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @statistic }
    end
  end

end
