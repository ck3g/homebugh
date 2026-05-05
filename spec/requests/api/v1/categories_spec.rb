require 'rails_helper'

RSpec.describe 'Categories API', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe 'GET /api/v1/categories' do
    context 'when authenticated' do
      let!(:category1) { create(:spending_category, user: user) }
      let!(:category2) { create(:income_category, user: user) }
      let!(:other_category) { create(:category, user: other_user) }

      it 'returns categories for the current user only' do
        get '/api/v1/categories', headers: headers

        expect(response).to have_http_status(:ok)
        ids = json_response['categories'].map { |c| c['id'] }
        expect(ids).to contain_exactly(category1.id, category2.id)
        expect(ids).not_to include(other_category.id)
      end

      it 'returns category attributes' do
        get '/api/v1/categories', headers: headers

        category = json_response['categories'].find { |c| c['id'] == category1.id }
        expect(category['name']).to eq(category1.name)
        expect(category['category_type_id']).to eq(CategoryType.expense)
        expect(category['inactive']).to eq(false)
        expect(category['status']).to eq('active')
        expect(category['client_uuid']).to be_nil
        expect(category['updated_at']).to be_present
      end

      it 'supports pagination' do
        get '/api/v1/categories', params: { page: 1, per_page: 1 }, headers: headers

        expect(json_response['categories'].length).to eq(1)
        expect(json_response['meta']['total_count']).to eq(2)
      end

      it 'supports updated_since filter' do
        category1.update_column(:updated_at, 2.days.ago)
        category2.update_column(:updated_at, 1.hour.ago)

        get '/api/v1/categories', params: { updated_since: 1.day.ago.iso8601 }, headers: headers

        ids = json_response['categories'].map { |c| c['id'] }
        expect(ids).to contain_exactly(category2.id)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/api/v1/categories'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/categories/:id' do
    let!(:category) { create(:category, user: user) }

    context 'when authenticated' do
      it 'returns the category' do
        get "/api/v1/categories/#{category.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['id']).to eq(category.id)
        expect(json_response['name']).to eq(category.name)
      end

      it 'returns not found for another user category' do
        other_category = create(:category, user: other_user)

        get "/api/v1/categories/#{other_category.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns not found for non-existent category' do
        get '/api/v1/categories/99999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/categories' do
    context 'when authenticated' do
      let!(:expense_type) { CategoryType.find_or_create_by!(id: CategoryType.expense, name: 'spending') }
      let(:valid_params) do
        { name: 'Groceries', category_type_id: expense_type.id }
      end

      it 'creates a category' do
        expect {
          post '/api/v1/categories', params: valid_params, headers: headers
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(json_response['name']).to eq('Groceries')
        expect(json_response['category_type_id']).to eq(CategoryType.expense)
      end

      it 'assigns the category to the current user' do
        post '/api/v1/categories', params: valid_params, headers: headers

        expect(Category.last.user).to eq(user)
      end

      it 'accepts client_uuid' do
        post '/api/v1/categories', params: valid_params.merge(client_uuid: 'ios-uuid-123'), headers: headers

        expect(response).to have_http_status(:created)
        expect(json_response['client_uuid']).to eq('ios-uuid-123')
      end

      it 'returns validation errors for missing name' do
        post '/api/v1/categories', params: { category_type_id: CategoryType.expense }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Validation failed')
        expect(json_response['details']['name']).to be_present
      end

      it 'returns validation errors for duplicate name' do
        create(:category, name: 'Groceries', user: user)

        post '/api/v1/categories', params: valid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']['name']).to be_present
      end
    end

    context 'without authentication' do
      it 'returns unauthorized' do
        post '/api/v1/categories', params: { name: 'Test' }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/categories/:id' do
    let!(:category) { create(:category, name: 'Old Name', user: user) }

    context 'when authenticated' do
      it 'updates the category name' do
        patch "/api/v1/categories/#{category.id}", params: { name: 'New Name' }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['name']).to eq('New Name')
        expect(category.reload.name).to eq('New Name')
      end

      it 'updates the inactive flag' do
        patch "/api/v1/categories/#{category.id}", params: { inactive: true }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['inactive']).to eq(true)
      end

      it 'returns not found for another user category' do
        other_category = create(:category, user: other_user)

        patch "/api/v1/categories/#{other_category.id}", params: { name: 'Hacked' }, headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'returns validation errors for blank name' do
        patch "/api/v1/categories/#{category.id}", params: { name: '' }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['details']['name']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/categories/:id' do
    context 'when authenticated' do
      let!(:category) { create(:category, user: user) }

      it 'soft-deletes the category' do
        delete "/api/v1/categories/#{category.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response['status']).to eq('ok')
        expect(category.reload.status).to eq('deleted')
      end

      it 'returns not found for another user category' do
        other_category = create(:category, user: other_user)

        delete "/api/v1/categories/#{other_category.id}", headers: headers

        expect(response).to have_http_status(:not_found)
      end

      it 'soft-deletes even when category has transactions' do
        create(:transaction, category: category, user: user, account: create(:account, user: user))

        delete "/api/v1/categories/#{category.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(category.reload.status).to eq('deleted')
      end
    end
  end
end
