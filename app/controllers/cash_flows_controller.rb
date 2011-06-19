class CashFlowsController < ApplicationController
  # GET /cash_flows
  # GET /cash_flows.xml
  def index
    @cash_flows = CashFlow.includes( :from_account, :to_account ).order( 'created_at desc' ).limit( 50 ).where( :user_id => current_user.id )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cash_flows }
    end
  end

  # GET /cash_flows/new
  # GET /cash_flows/new.xml
  def new
    @cash_flow = CashFlow.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cash_flow }
    end
  end

  # GET /cash_flows/1/edit
  def edit
    @cash_flow = CashFlow.where( :user_id => current_user.id ).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # POST /cash_flows
  # POST /cash_flows.xml
  def create
    @cash_flow = CashFlow.new(params[:cash_flow])
    @cash_flow.user_id = current_user.id
    @accounts = Account.where( :user_id => current_user.id )

    respond_to do |format|
      if @cash_flow.move_funds
        format.html { redirect_to(cash_flows_path, :notice => t( 'parts.cash_flows.successfully_updated' )) }
        format.xml  { render :xml => cash_flow_path, :status => :created, :location => @cash_flow }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cash_flow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cash_flows/1
  # PUT /cash_flows/1.xml
  def update
    begin
      @cash_flow = CashFlow.where( :user_id => current_user.id ).find(params[:id])
    rescue ActiveRecord.RecordNotFound
      render_404
    end

    respond_to do |format|
      if @cash_flow.extended_update_attributes(params[:cash_flow])
        format.html { redirect_to(cash_flows_path, :notice => t( 'parts.cash_flows.successfully_updated' )) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cash_flow.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cash_flows/1
  # DELETE /cash_flows/1.xml
  def destroy
    begin
      @cash_flow = CashFlow.where( :user_id => current_user.id ).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404
      return
    end
    @cash_flow.extended_destroy

    respond_to do |format|
      format.html { redirect_to(cash_flows_url) }
      format.xml  { head :ok }
    end
  end
end
