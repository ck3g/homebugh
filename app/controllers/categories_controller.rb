class CategoriesController < ApplicationController
  before_filter :authenticate_user!

  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.includes( :category_type ).where( :user_id => current_user.id )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    begin
      raise ActiveRecord::RecordNotFound
      # unavailable now
      @category = Category.find(params[:id]).where( :user_id => current_user.id )
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/new
  # GET /categories/new.xml
  def new
    @category = Category.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @category }
    end
  end

  # GET /categories/1/edit
  def edit
    @category = Category.where( :user_id => current_user.id ).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # POST /categories
  # POST /categories.xml
  def create
    @category = Category.new(params[:category])
    @category.user_id = current_user.id

    respond_to do |format|
      if @category.save
        format.html { redirect_to(categories_path, :notice => t( 'parts.categories.successfully_created') ) }
        format.xml  { render :xml => @category, :status => :created, :location => @category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /categories/1
  # PUT /categories/1.xml
  def update
    @category = Category.find(params[:id])

    respond_to do |format|
      if @category.update_attributes(params[:category])
        format.html { redirect_to(categories_path, :notice => t( 'parts.categories.successfully_updated') ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /categories/1
  # DELETE /categories/1.xml
  def destroy
    begin
    @category = Category.where( :user_id => current_user.id ).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end

    @category.destroy

    respond_to do |format|
      format.html { redirect_to(categories_url) }
      format.xml  { head :ok }
    end
  end
end
