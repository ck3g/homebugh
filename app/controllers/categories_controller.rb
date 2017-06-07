class CategoriesController < ApplicationController
  authorize_resource
  before_filter :find_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user
      .categories
      .search(params[:term])
      .includes(:category_type)
      .by_recently_used
      .page(params[:page])
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = current_user.categories.new safe_params

    if @category.save
      redirect_to categories_path, notice: t('parts.categories.successfully_created')
    else
      render "new"
    end
  end

  def update
    if @category.update_attributes safe_params
      redirect_to categories_path, notice: t('parts.categories.successfully_updated')
    else
      render "edit"
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private
  def find_category
    @category = current_user.categories.find(params[:id])
  end

  def safe_params
    params.require(:category).permit(:name, :category_type_id, :inactive)
  end
end
