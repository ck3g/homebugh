module Api
  module V1
    class RecurringCashFlowsController < BaseController
      before_action :find_recurring_cash_flow, only: [:show, :update, :destroy, :move_to_next_transfer, :perform_transfer]

      def index
        recurring_cash_flows = current_user.recurring_cash_flows
                                .updated_since(params[:updated_since])
                                .page(params[:page]).per(per_page)

        render json: {
          recurring_cash_flows: RecurringCashFlowBlueprint.render_as_hash(recurring_cash_flows),
          meta: pagination_meta(recurring_cash_flows)
        }
      end

      def show
        render json: RecurringCashFlowBlueprint.render_as_hash(@recurring_cash_flow)
      end

      def create
        recurring_cash_flow = current_user.recurring_cash_flows.new(create_params)

        if recurring_cash_flow.save
          render json: RecurringCashFlowBlueprint.render_as_hash(recurring_cash_flow), status: :created
        else
          render_validation_errors(recurring_cash_flow)
        end
      end

      def update
        if @recurring_cash_flow.update(update_params)
          render json: RecurringCashFlowBlueprint.render_as_hash(@recurring_cash_flow)
        else
          render_validation_errors(@recurring_cash_flow)
        end
      end

      def destroy
        @recurring_cash_flow.destroy
        render json: { status: 'ok' }
      end

      def move_to_next_transfer
        @recurring_cash_flow.move_to_next_transfer
        render json: RecurringCashFlowBlueprint.render_as_hash(@recurring_cash_flow)
      end

      def perform_transfer
        cash_flow = current_user.cash_flows.new(
          amount: @recurring_cash_flow.amount,
          from_account: @recurring_cash_flow.from_account,
          to_account: @recurring_cash_flow.to_account
        )

        if cash_flow.save
          @recurring_cash_flow.move_to_next_transfer
          render json: CashFlowBlueprint.render_as_hash(cash_flow), status: :created
        else
          render_validation_errors(cash_flow)
        end
      end

      private

      def find_recurring_cash_flow
        @recurring_cash_flow = current_user.recurring_cash_flows.find_by(id: params[:id])
        render_not_found unless @recurring_cash_flow
      end

      def create_params
        params.permit(:amount, :from_account_id, :to_account_id,
                      :frequency, :frequency_amount, :next_transfer_on, :ends_on, :client_uuid)
      end

      def update_params
        params.permit(:amount, :from_account_id, :to_account_id,
                      :frequency, :frequency_amount, :next_transfer_on, :ends_on)
      end
    end
  end
end
