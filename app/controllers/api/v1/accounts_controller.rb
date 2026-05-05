module Api
  module V1
    class AccountsController < BaseController
      def index
        accounts = current_user.accounts
                    .updated_since(params[:updated_since])
                    .page(params[:page]).per(per_page)

        render json: {
          accounts: AccountBlueprint.render_as_hash(accounts),
          meta: pagination_meta(accounts)
        }
      end

      def show
        account = current_user.accounts.find_by(id: params[:id])
        return render_not_found unless account

        render json: AccountBlueprint.render_as_hash(account)
      end

      def create
        account = current_user.accounts.new(account_params)

        if account.save
          render json: AccountBlueprint.render_as_hash(account), status: :created
        else
          render_validation_errors(account)
        end
      end

      def update
        account = current_user.accounts.find_by(id: params[:id])
        return render_not_found unless account

        if account.update(update_params)
          render json: AccountBlueprint.render_as_hash(account)
        else
          render_validation_errors(account)
        end
      end

      def destroy
        account = current_user.accounts.find_by(id: params[:id])
        return render_not_found unless account

        account.destroy
        if account.deleted?
          render json: { status: 'ok' }
        else
          render json: {
            error: 'Account cannot be deleted',
            details: { balance: ['must be zero to delete'] }
          }, status: :unprocessable_entity
        end
      end

      private

      def account_params
        params.permit(:name, :currency_id, :show_in_summary, :client_uuid)
      end

      def update_params
        params.permit(:name, :show_in_summary)
      end
    end
  end
end
