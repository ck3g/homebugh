class BudgetsController < ApplicationController
  authorize_resource

  before_filter :find_budget, only: [:edit, :update, :destroy]

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

  def edit
  end

  def update
    if @budget.update_attributes safe_params
      redirect_to budgets_path
    else
      render :edit
    end
  end

  def destroy
    @budget.destroy
    redirect_to budgets_path
  end

  private

  def safe_params
    params.require(:budget).permit(:category_id, :limit, :currency_id)
  end

  def find_budget
    @budget = Budget.find params[:id]
  end
end
