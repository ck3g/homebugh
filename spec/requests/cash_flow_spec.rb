# encoding: utf-8
require "spec_helper"

describe "Cash Flows" do

  before(:each) do
    I18n.locale = :en
    @user = create(:user)
    login @user

    @from_account = create(:from_account, user: @user)
    @to_account = create(:to_account, user: @user)
  end

  describe "cash_flows_path" do
    before do
      visit cash_flows_path
    end

    it "get list of cash flows" do
      page.should have_content("List of cash flows")
    end

    it "have link to Move funds" do
      page.has_link?("Move funds").should be_true
    end
  end

  describe "create" do
    context "when success" do
      before { create_flow }
      subject { page }
      it { should have_content("Funds was successfully moved.") }
      it { should have_content("From Account → To Account") }
      it { should have_content("15.00") }
      it { current_path.should == cash_flows_path }
    end

    context "when fail" do

    end
  end

  describe "#edit" do
    context "when wisit edit page" do
      before do
        cash_flow = create(:cash_flow, user: @user, from_account: @from_account, to_account: @to_account)
        visit edit_cash_flow_path(cash_flow)
        select "To Account", from: "cash_flow_from_account_id"
        select "From Account", from: "cash_flow_to_account_id"
        fill_in "cash_flow_amount", with: "25"
        click_button "cash_flow_submit"
      end

      subject { page }
      it { should have_content("Funds was successfully moved.") }
      it { should have_content("To Account → From Account") }
      it { should have_content("25.00") }
      it { current_path.should == cash_flows_path }
    end
  end

  it "should destroy flow" do
    create_flow

    page.should have_content("From Account → To Account")
    page.should have_content("15.00")
    click_link "Destroy"
    page.should_not have_content("From Account → To Account")
    page.should_not have_content("15.00")
  end

  it "should raise validation on create" do
    visit new_cash_flow_path
    select "From Account", :from => "cash_flow_from_account_id"
    select "From Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => "0"

    click_button "cash_flow_submit"
    page.should have_content("You cannot move funds to same account")
    page.should have_content("Cannot be less than 0.01")
  end

  it "should raise validation on update" do
    create_flow
    visit cash_flows_path
    click_link "Edit"

    select "From Account", :from => "cash_flow_from_account_id"
    select "From Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => "0"

    click_button "cash_flow_submit"
    page.should have_content("You cannot move funds to same account")
    page.should have_content("Cannot be less than 0.01")
  end

  private

  def create_flow
    visit new_cash_flow_path
    select "From Account", :from => "cash_flow_from_account_id"
    select "To Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => 15
    click_button "cash_flow_submit"
  end

end
