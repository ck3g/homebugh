class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :index, :dashboard
    
    # Get current month spending data for Euro currency (if available)
    eur_currency = Currency.find_by(name: 'EUR')
    if eur_currency && current_user
      @current_month_stats = Statistic.current_month_stats(
        eur_currency.id,
        current_user.id
      )
    else
      @current_month_stats = []
    end
  end
end