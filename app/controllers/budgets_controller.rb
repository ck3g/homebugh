class BudgetsController < ApplicationController
  def index
    @budgets = current_user.budgets
  end

  def new
    @budget = Budget.new
  end

  def create
    @budget = current_user.budgets.new safe_params
    if @budget.save
      redirect_to budgets_path
    else
      render :new
    end
  end

  private

  def safe_params
    params.require(:budget).permit(:category_id, :limit, :currency_id)
  end
end
