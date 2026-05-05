module Api
  module V1
    class CurrenciesController < BaseController
      def index
        currencies = Currency.page(params[:page]).per(per_page)

        render json: {
          currencies: CurrencyBlueprint.render_as_hash(currencies),
          meta: pagination_meta(currencies)
        }
      end

      def show
        currency = Currency.find_by(id: params[:id])
        return render_not_found unless currency

        render json: CurrencyBlueprint.render_as_hash(currency)
      end
    end
  end
end
