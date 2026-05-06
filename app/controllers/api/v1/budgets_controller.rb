module Api
  module V1
    class BudgetsController < BaseController
      def index
        budgets = current_user.budgets
                    .updated_since(params[:updated_since])
                    .page(params[:page]).per(per_page)

        render json: {
          budgets: BudgetBlueprint.render_as_hash(budgets),
          meta: pagination_meta(budgets)
        }
      end

      def show
        budget = current_user.budgets.find_by(id: params[:id])
        return render_not_found unless budget

        render json: BudgetBlueprint.render_as_hash(budget)
      end

      def create
        budget = current_user.budgets.new(create_params)

        if budget.save
          render json: BudgetBlueprint.render_as_hash(budget), status: :created
        else
          render_validation_errors(budget)
        end
      end

      def update
        budget = current_user.budgets.find_by(id: params[:id])
        return render_not_found unless budget

        if budget.update(update_params)
          render json: BudgetBlueprint.render_as_hash(budget)
        else
          render_validation_errors(budget)
        end
      end

      def destroy
        budget = current_user.budgets.find_by(id: params[:id])
        return render_not_found unless budget

        budget.destroy
        render json: { status: 'ok' }
      end

      private

      def create_params
        params.permit(:category_id, :currency_id, :limit, :client_uuid)
      end

      def update_params
        params.permit(:category_id, :currency_id, :limit)
      end
    end
  end
end
