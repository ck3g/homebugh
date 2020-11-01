require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  describe 'PUT #update' do
    subject(:update) { put :update, params: { user: user_params } }

    let(:user_params) do
      {
        email: 'new-user-email@example.com',
        password: 'new-password',
        password_confirmation: 'new-password',
        current_password: 'password'
      }
    end

    context 'with regular user' do
      login_user

      it 'changes user email' do
        expect { update }.to change { User.last!.email }.to 'new-user-email@example.com'
      end

      it 'changes user password' do
        update

        expect(User.last!.valid_password?('new-password')).to be_truthy
      end
    end

    context 'with demo user' do
      login_demo_user

      it 'does not change user email' do
        expect { update }.not_to change { User.last!.email }
      end

      it 'does not change user password' do
        update

        expect(User.last!.valid_password?('new-password')).to be_falsey
      end
    end
  end
end
