module Api
  module V1
    class StatisticsController < BaseController
      def index
        return render_bad_request('year and month are required') unless params[:year].present? && params[:month].present?

        year = params[:year].to_i
        month = params[:month].to_i
        return render_bad_request('month must be between 1 and 12') unless month.between?(1, 12)
        return render_bad_request('year must be positive') unless year > 0

        currency_id = params[:currency_id]
        date = Date.new(year, month, 1)

        if current_month?(date)
          render json: current_month_stats(date, currency_id)
        else
          render json: past_month_stats(date, currency_id)
        end
      end

      def months
        currency_id = params[:currency_id]
        available = available_months(currency_id)

        render json: available
      end

      private

      def current_month?(date)
        date.year == Date.current.year && date.month == Date.current.month
      end

      def current_month_stats(date, currency_id)
        stats = TransactionStats.new(currency_id, current_user.id, date.beginning_of_month, date.end_of_month)

        {
          year: date.year,
          month: date.month,
          currency_id: currency_id.present? ? currency_id.to_i : nil,
          total_income: stats.total_income,
          total_expenses: stats.total_spending,
          categories: build_categories(stats.get_income_categories, CategoryType.income) +
                      build_categories(stats.get_spending_categories, CategoryType.expense)
        }
      end

      def past_month_stats(date, currency_id)
        aggregated = current_user.aggregated_transactions
                      .where(period_started_at: date.beginning_of_month.beginning_of_day..date.beginning_of_month.end_of_day)
        aggregated = aggregated.where(currency_id: currency_id) if currency_id.present?

        total_income = aggregated.income.sum(:amount)
        total_expenses = aggregated.spending.sum(:amount)

        categories = aggregated.includes(:category).map do |at|
          {
            category_id: at.category_id,
            name: at.category.name,
            amount: at.amount,
            category_type_id: at.category_type_id
          }
        end

        {
          year: date.year,
          month: date.month,
          currency_id: currency_id.present? ? currency_id.to_i : nil,
          total_income: total_income,
          total_expenses: total_expenses,
          categories: categories
        }
      end

      def build_categories(category_data, category_type_id)
        categories_by_name = current_user.categories.index_by(&:name)

        category_data.map do |cat|
          {
            category_id: categories_by_name[cat[:name]]&.id,
            name: cat[:name],
            amount: cat[:sum],
            category_type_id: category_type_id
          }
        end
      end

      def available_months(currency_id)
        months = []

        # Current month if user has transactions
        current_transactions = current_user.transactions
                                .where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
        if currency_id.present?
          current_transactions = current_transactions.joins(:account).where(accounts: { currency_id: currency_id })
        end
        if current_transactions.exists?
          months << { year: Date.current.year, month: Date.current.month }
        end

        # Past months from aggregated transactions
        scope = current_user.aggregated_transactions
        scope = scope.where(currency_id: currency_id) if currency_id.present?
        scope.select(:period_started_at).distinct.order(period_started_at: :desc).each do |at|
          date = at.period_started_at.to_date
          months << { year: date.year, month: date.month }
        end

        months.uniq
      end

      def render_bad_request(message)
        render json: { error: message }, status: :bad_request
      end
    end
  end
end
