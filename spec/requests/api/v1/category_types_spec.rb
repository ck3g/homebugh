require 'rails_helper'

RSpec.describe 'Category Types API', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/category_types' do
    context 'when authenticated' do
      before do
        CategoryType.find_or_create_by!(id: 1, name: 'income')
        CategoryType.find_or_create_by!(id: 2, name: 'spending')
      end

      it 'returns all category types' do
        get '/api/v1/category_types', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['category_types'].length).to eq(2)
      end

      it 'returns category type attributes with correct names' do
        get '/api/v1/category_types', headers: headers

        income = json_response['category_types'].find { |ct| ct['id'] == 1 }
        expense = json_response['category_types'].find { |ct| ct['id'] == 2 }

        expect(income['name']).to eq('income')
        expect(expense['name']).to eq('expense')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/category_types'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/category_types/:id' do
    before do
      CategoryType.find_or_create_by!(id: 1, name: 'income')
      CategoryType.find_or_create_by!(id: 2, name: 'spending')
    end

    context 'when authenticated' do
      it 'returns the category type' do
        get '/api/v1/category_types/1', headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(1)
        expect(json_response['name']).to eq('income')
      end

      it 'maps spending to expense' do
        get '/api/v1/category_types/2', headers: headers

        expect(json_response['name']).to eq('expense')
      end

      it 'returns not found for non-existent category type' do
        get '/api/v1/category_types/99999', headers: headers

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Not found')
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/category_types/1'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
