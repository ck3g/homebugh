require 'rails_helper'

RSpec.describe 'Statistics API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency, name: 'US Dollar', unit: '$') }
  let(:account) { create(:account, user: user, currency: currency) }
  let(:income_category) { create(:income_category, user: user) }
  let(:expense_category) { create(:spending_category, user: user) }

  describe 'GET /api/v1/statistics' do
    context 'when authenticated' do
      context 'for the current month' do
        before do
          create(:transaction, user: user, account: account, category: income_category, summ: 3000.0)
          create(:transaction, user: user, account: account, category: expense_category, summ: 500.0)
          create(:transaction, user: user, account: account, category: expense_category, summ: 300.0)
        end

        it 'returns current month statistics' do
          get '/api/v1/statistics', params: {
            year: Date.current.year, month: Date.current.month, currency_id: currency.id
          }, headers: headers

          expect(response).to have_http_status(:ok)
          expect(json_response['year']).to eq(Date.current.year)
          expect(json_response['month']).to eq(Date.current.month)
          expect(json_response['currency_id']).to eq(currency.id)
          expect(json_response['total_income'].to_f).to eq(3000.0)
          expect(json_response['total_expenses'].to_f).to eq(800.0)
        end

        it 'includes per-category breakdown' do
          get '/api/v1/statistics', params: {
            year: Date.current.year, month: Date.current.month, currency_id: currency.id
          }, headers: headers

          categories = json_response['categories']
          expect(categories).to be_an(Array)
          expect(categories.length).to eq(2)

          income_cat = categories.find { |c| c['category_type_id'] == CategoryType.income }
          expect(income_cat['amount'].to_f).to eq(3000.0)
          expect(income_cat['category_id']).to eq(income_category.id)
          expect(income_cat['name']).to eq(income_category.name)
        end
      end

      context 'for a past month (aggregated data)' do
        let(:past_date) { 2.months.ago.beginning_of_month }

        before do
          create(:aggregated_transaction,
            user: user, category: income_category, category_type: income_category.category_type,
            currency: currency, amount: 5000.0,
            period_started_at: past_date, period_ended_at: past_date.end_of_month)
          create(:aggregated_transaction,
            user: user, category: expense_category, category_type: expense_category.category_type,
            currency: currency, amount: 2000.0,
            period_started_at: past_date, period_ended_at: past_date.end_of_month)
        end

        it 'returns past month statistics from aggregated data' do
          get '/api/v1/statistics', params: {
            year: past_date.year, month: past_date.month, currency_id: currency.id
          }, headers: headers

          expect(response).to have_http_status(:ok)
          expect(json_response['total_income'].to_f).to eq(5000.0)
          expect(json_response['total_expenses'].to_f).to eq(2000.0)
        end

        it 'includes per-category breakdown from aggregated data' do
          get '/api/v1/statistics', params: {
            year: past_date.year, month: past_date.month, currency_id: currency.id
          }, headers: headers

          categories = json_response['categories']
          expect(categories.length).to eq(2)
        end
      end

      it 'requires year and month params' do
        get '/api/v1/statistics', params: { currency_id: currency.id }, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(json_response['error']).to be_present
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/statistics'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/statistics/months' do
    context 'when authenticated' do
      before do
        # Current month transaction
        create(:transaction, user: user, account: account, category: expense_category, summ: 10.0)

        # Past month aggregated data
        past1 = 2.months.ago.beginning_of_month
        past2 = 3.months.ago.beginning_of_month
        create(:aggregated_transaction,
          user: user, category: expense_category, category_type: expense_category.category_type,
          currency: currency, amount: 100.0,
          period_started_at: past1, period_ended_at: past1.end_of_month)
        create(:aggregated_transaction,
          user: user, category: expense_category, category_type: expense_category.category_type,
          currency: currency, amount: 200.0,
          period_started_at: past2, period_ended_at: past2.end_of_month)
      end

      it 'returns available months' do
        get '/api/v1/statistics/months', params: { currency_id: currency.id }, headers: headers

        expect(response).to have_http_status(:ok)
        months = json_response
        expect(months).to be_an(Array)
        expect(months.length).to be >= 2
      end

      it 'returns months with year and month fields' do
        get '/api/v1/statistics/months', params: { currency_id: currency.id }, headers: headers

        months = json_response
        months.each do |m|
          expect(m).to have_key('year')
          expect(m).to have_key('month')
        end
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/statistics/months'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
