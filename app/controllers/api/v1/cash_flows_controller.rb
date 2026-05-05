module Api
  module V1
    class CashFlowsController < BaseController
      def index
        cash_flows = current_user.cash_flows
                      .updated_since(params[:updated_since])
                      .page(params[:page]).per(per_page)

        render json: {
          cash_flows: CashFlowBlueprint.render_as_hash(cash_flows),
          meta: pagination_meta(cash_flows)
        }
      end

      def show
        cash_flow = current_user.cash_flows.find_by(id: params[:id])
        return render_not_found unless cash_flow

        render json: CashFlowBlueprint.render_as_hash(cash_flow)
      end

      def create
        cash_flow = current_user.cash_flows.new(cash_flow_params)

        if cash_flow.save
          render json: CashFlowBlueprint.render_as_hash(cash_flow), status: :created
        else
          render_validation_errors(cash_flow)
        end
      end

      def destroy
        cash_flow = current_user.cash_flows.find_by(id: params[:id])
        return render_not_found unless cash_flow

        cash_flow.destroy
        render json: { status: 'ok' }
      end

      private

      def cash_flow_params
        params.permit(:amount, :initial_amount, :from_account_id, :to_account_id, :client_uuid)
      end
    end
  end
end
