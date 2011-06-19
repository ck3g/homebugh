class TransactionsController < ApplicationController
  before_filter :authenticate_user!

  # GET /transactions
  # GET /transactions.xml
  def index
    @transactions = Transaction.includes( :category, :account ).order( 'created_at desc' ).limit( 50 ).where( :user_id => current_user.id )
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @transactions }
    end
  end

  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    begin
      raise ActiveRecord::RecordNotFound
      # unavailable now
      @transaction = Transaction.where( :user_id => current_user.id ).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = Transaction.new
    @categories = Category.where( :user_id => current_user.id )
    @accounts = Account.where( :user_id => current_user.id )

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    begin
      @transaction = Transaction.where( :user_id => current_user.id ).find(params[:id])
      @categories = Category.where( :user_id => current_user.id )
      @accounts = Account.where( :user_id => current_user.id )
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])
    @transaction.user_id = current_user.id

    respond_to do |format|
      if @transaction.extended_save
        format.html { redirect_to(transactions_path, :notice => t( 'parts.transactions.successfully_created' )) }
        format.xml  { render :xml => @transaction, :status => :created, :location => @transaction }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /transactions/1
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      if @transaction.extended_update_attributes(params[:transaction])
        format.html { redirect_to(transactions_path , :notice => t( 'parts.transactions.successfully_updated' )) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    begin
      @transaction = Transaction.where( :user_id => current_user.id ).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end
    @transaction.extended_destroy

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end
end
