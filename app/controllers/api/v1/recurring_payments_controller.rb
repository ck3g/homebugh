module Api
  module V1
    class RecurringPaymentsController < BaseController
      before_action :find_recurring_payment, only: [:show, :update, :destroy, :move_to_next_payment, :create_transaction]

      def index
        recurring_payments = current_user.recurring_payments
                              .updated_since(params[:updated_since])
                              .page(params[:page]).per(per_page)

        render json: {
          recurring_payments: RecurringPaymentBlueprint.render_as_hash(recurring_payments),
          meta: pagination_meta(recurring_payments)
        }
      end

      def show
        render json: RecurringPaymentBlueprint.render_as_hash(@recurring_payment)
      end

      def create
        recurring_payment = current_user.recurring_payments.new(recurring_payment_params)

        if recurring_payment.save
          render json: RecurringPaymentBlueprint.render_as_hash(recurring_payment), status: :created
        else
          render_validation_errors(recurring_payment)
        end
      end

      def update
        if @recurring_payment.update(recurring_payment_params)
          render json: RecurringPaymentBlueprint.render_as_hash(@recurring_payment)
        else
          render_validation_errors(@recurring_payment)
        end
      end

      def destroy
        @recurring_payment.destroy
        render json: { status: 'ok' }
      end

      def move_to_next_payment
        @recurring_payment.move_to_next_payment
        render json: RecurringPaymentBlueprint.render_as_hash(@recurring_payment)
      end

      def create_transaction
        transaction = current_user.transactions.new(
          summ: @recurring_payment.amount,
          comment: @recurring_payment.title,
          category: @recurring_payment.category,
          account: @recurring_payment.account
        )

        if transaction.save
          @recurring_payment.move_to_next_payment
          render json: TransactionBlueprint.render_as_hash(transaction), status: :created
        else
          render_validation_errors(transaction)
        end
      end

      private

      def find_recurring_payment
        @recurring_payment = current_user.recurring_payments.find_by(id: params[:id])
        render_not_found unless @recurring_payment
      end

      def recurring_payment_params
        params.permit(:title, :amount, :account_id, :category_id,
                      :frequency, :frequency_amount, :next_payment_on, :ends_on, :client_uuid)
      end
    end
  end
end
