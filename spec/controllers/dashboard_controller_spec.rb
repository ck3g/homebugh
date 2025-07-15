require 'rails_helper'

describe DashboardController do
  let(:user) { create :user_example_com }

  describe '#index' do
    context 'when user is authenticated' do
      before do
        sign_in user
      end

      it 'renders successfully' do
        get :index
        expect(response).to be_successful
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end
    end

    context 'when user is not authenticated' do
      it 'redirects to sign in' do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end