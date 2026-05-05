module Api
  module V1
    class TransactionsController < BaseController
      def index
        transactions = current_user.transactions
                        .updated_since(params[:updated_since])
                        .account(params[:account_id])
                        .category(params[:category_id])
                        .page(params[:page]).per(per_page)

        render json: {
          transactions: TransactionBlueprint.render_as_hash(transactions),
          meta: pagination_meta(transactions)
        }
      end

      def show
        transaction = current_user.transactions.find_by(id: params[:id])
        return render_not_found unless transaction

        render json: TransactionBlueprint.render_as_hash(transaction)
      end

      def create
        transaction = current_user.transactions.new(create_params)

        if transaction.save
          render json: TransactionBlueprint.render_as_hash(transaction), status: :created
        else
          render_validation_errors(transaction)
        end
      end

      def update
        transaction = current_user.transactions.find_by(id: params[:id])
        return render_not_found unless transaction

        if transaction.update(update_params)
          render json: TransactionBlueprint.render_as_hash(transaction)
        else
          render_validation_errors(transaction)
        end
      end

      def destroy
        transaction = current_user.transactions.find_by(id: params[:id])
        return render_not_found unless transaction

        transaction.destroy
        render json: { status: 'ok' }
      end

      private

      def create_params
        params.permit(:account_id, :category_id, :comment, :client_uuid).tap do |p|
          p[:summ] = params[:amount] if params[:amount].present?
        end
      end

      def update_params
        params.permit(:comment)
      end
    end
  end
end
