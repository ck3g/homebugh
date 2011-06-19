require 'test_helper'

class CashFlowsControllerTest < ActionController::TestCase
  setup do
    @cash_flow = cash_flows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cash_flows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cash_flow" do
    assert_difference('CashFlow.count') do
      post :create, :cash_flow => @cash_flow.attributes
    end

    assert_redirected_to cash_flow_path(assigns(:cash_flow))
  end

  test "should show cash_flow" do
    get :show, :id => @cash_flow.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @cash_flow.to_param
    assert_response :success
  end

  test "should update cash_flow" do
    put :update, :id => @cash_flow.to_param, :cash_flow => @cash_flow.attributes
    assert_redirected_to cash_flow_path(assigns(:cash_flow))
  end

  test "should destroy cash_flow" do
    assert_difference('CashFlow.count', -1) do
      delete :destroy, :id => @cash_flow.to_param
    end

    assert_redirected_to cash_flows_path
  end
end
