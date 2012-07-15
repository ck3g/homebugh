class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_category, only: [:show, :edit, :update, :destroy]

  def index
    @categories = current_user.categories.includes(:category_type)
  end

  def show
  end

  def new
    @category = Category.new
  end

  def edit
  end

  def create
    @category = current_user.categories.new(params[:category])

    if @category.save
      redirect_to categories_path, notice: t('parts.categories.successfully_created')
    else
      render "new"
    end
  end

  def update
    if @category.update_attributes(params[:category])
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
end
