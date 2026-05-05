require 'rails_helper'

RSpec.describe 'Budgets API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:currency) { create(:currency) }
  let(:category) { create(:spending_category, user: user) }

  describe 'GET /api/v1/budgets' do
    context 'when authenticated' do
      let!(:budget1) { create(:budget, user: user, category: category, currency: currency) }
      let!(:budget2) { create(:budget, user: user, currency: currency) }
      let!(:other_budget) { create(:budget, user: other_user) }

      it 'returns budgets for the current user only' do
        get '/api/v1/budgets', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['budgets'].map { |b| b['id'] }
        expect(ids).to contain_exactly(budget1.id, budget2.id)
        expect(ids).not_to include(other_budget.id)
      end

      it 'returns budget attributes' do
        get '/api/v1/budgets', headers: headers

        budget = json_response['budgets'].find { |b| b['id'] == budget1.id }
        expect(budget['category_id']).to eq(category.id)
        expect(budget['currency_id']).to eq(currency.id)
        expect(budget['limit']).to eq('100.99')
        expect(budget['client_uuid']).to be_nil
        expect(budget['created_at']).to be_present
        expect(budget['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/budgets', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['budgets'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        budget1.update_column(:updated_at, 2.days.ago)
        budget2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/budgets', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['budgets'].map { |b| b['id'] }
        expect(ids).to contain_exactly(budget2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/budgets'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/budgets/:id' do
    let!(:budget) { create(:budget, user: user, category: category, currency: currency) }

    context 'when authenticated' do
      it 'returns the budget' do
        get "/api/v1/budgets/#{budget.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(budget.id)
        expect(json_response['limit']).to eq('100.99')
      end

      it 'returns not found for another user budget' do
        other_budget = create(:budget, user: other_user)

        get "/api/v1/budgets/#{other_budget.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found for non-existent budget' do
        get '/api/v1/budgets/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/budgets' do
    context 'when authenticated' do
      let(:valid_params) do
        { category_id: category.id, currency_id: currency.id, limit: 500.00 }
      end

      it 'creates a budget' do
        expect {
          post '/api/v1/budgets', params: valid_params, headers: headers
        }.to change(Budget, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['limit']).to eq('500.0')
        expect(json_response['category_id']).to eq(category.id)
        expect(json_response['currency_id']).to eq(currency.id)
      end

      it 'assigns the budget to the current user' do
        post '/api/v1/budgets', params: valid_params, headers: headers

        expect(Budget.last.user).to eq(user)
      end

      it 'accepts client_uuid' do
        post '/api/v1/budgets', params: valid_params.merge(client_uuid: 'ios-budget-uuid'), headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-budget-uuid')
      end

      it 'returns validation errors for missing limit' do
        post '/api/v1/budgets', params: { category_id: category.id, currency_id: currency.id }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
      end

      it 'returns validation errors for limit of zero' do
        post '/api/v1/budgets', params: valid_params.merge(limit: 0), headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/budgets', params: { limit: 100 }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/budgets/:id' do
    let!(:budget) { create(:budget, user: user, category: category, currency: currency, limit: 200.00) }

    context 'when authenticated' do
      it 'updates the limit' do
        patch "/api/v1/budgets/#{budget.id}", params: { limit: 350.00 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['limit']).to eq('350.0')
        expect(budget.reload.limit).to eq(350.00)
      end

      it 'updates category and currency' do
        new_category = create(:spending_category, user: user)
        new_currency = create(:currency, name: 'Euro', unit: '€')

        patch "/api/v1/budgets/#{budget.id}", params: {
          category_id: new_category.id, currency_id: new_currency.id
        }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['category_id']).to eq(new_category.id)
        expect(json_response['currency_id']).to eq(new_currency.id)
      end

      it 'returns not found for another user budget' do
        other_budget = create(:budget, user: other_user)

        patch "/api/v1/budgets/#{other_budget.id}", params: { limit: 999 }, headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns validation errors for invalid limit' do
        patch "/api/v1/budgets/#{budget.id}", params: { limit: -10 }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /api/v1/budgets/:id' do
    context 'when authenticated' do
      let!(:budget) { create(:budget, user: user, category: category, currency: currency) }

      it 'deletes the budget' do
        expect {
          delete "/api/v1/budgets/#{budget.id}", headers: headers
        }.to change(Budget, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
      end

      it 'returns not found for another user budget' do
        other_budget = create(:budget, user: other_user)

        delete "/api/v1/budgets/#{other_budget.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
