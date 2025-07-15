class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :index, :dashboard
    # Dashboard will show account summary and potentially other widgets
  end
end