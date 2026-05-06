require 'rails_helper'

RSpec.describe Api::TokenService do
  describe '.authenticate' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns an auth session with a token' do
        result = described_class.authenticate('test@example.com', 'password123')

        expect(result).to be_a(AuthSession)
        expect(result.token).to be_present
        expect(result.user).to eq(user)
        expect(result.expired_at).to be_within(1.minute).of(Api::TokenService::TOKEN_LIFETIME.from_now)
      end

      it 'persists the auth session' do
        expect {
          described_class.authenticate('test@example.com', 'password123')
        }.to change(AuthSession, :count).by(1)
      end
    end

    context 'with wrong password' do
      it 'returns nil' do
        result = described_class.authenticate('test@example.com', 'wrongpassword')

        expect(result).to be_nil
      end
    end

    context 'with non-existent email' do
      it 'returns nil' do
        result = described_class.authenticate('nobody@example.com', 'password123')

        expect(result).to be_nil
      end
    end

    context 'with unconfirmed user' do
      let!(:unconfirmed_user) { create(:user, email: 'unconfirmed@example.com', confirmed_at: nil) }

      it 'returns nil' do
        result = described_class.authenticate('unconfirmed@example.com', 'password')

        expect(result).to be_nil
      end
    end
  end

  describe '.find_user_by_token' do
    let(:user) { create(:user) }

    context 'with a valid token close to expiry' do
      let!(:session) { create(:auth_session, user: user, expired_at: 10.days.from_now) }

      it 'returns the user' do
        result = described_class.find_user_by_token(session.token)

        expect(result).to eq(user)
      end

      it 'extends the token expiry' do
        described_class.find_user_by_token(session.token)

        session.reload
        expect(session.expired_at).to be_within(1.minute).of(Api::TokenService::TOKEN_LIFETIME.from_now)
      end
    end

    context 'with a valid token far from expiry' do
      let!(:session) { create(:auth_session, user: user, expired_at: 60.days.from_now) }

      it 'returns the user' do
        result = described_class.find_user_by_token(session.token)

        expect(result).to eq(user)
      end

      it 'does not extend the token expiry' do
        original_expiry = session.expired_at

        described_class.find_user_by_token(session.token)

        session.reload
        expect(session.expired_at).to be_within(1.second).of(original_expiry)
      end
    end

    context 'with an expired token' do
      let!(:session) { create(:auth_session, user: user, expired_at: 1.day.ago) }

      it 'returns nil' do
        result = described_class.find_user_by_token(session.token)

        expect(result).to be_nil
      end
    end

    context 'with a non-existent token' do
      it 'returns nil' do
        result = described_class.find_user_by_token('nonexistent-token')

        expect(result).to be_nil
      end
    end
  end

  describe '.revoke' do
    let(:user) { create(:user) }
    let!(:session) { create(:auth_session, user: user) }

    it 'deletes the auth session' do
      expect {
        described_class.revoke(session.token)
      }.to change(AuthSession, :count).by(-1)
    end

    it 'returns true when token exists' do
      result = described_class.revoke(session.token)

      expect(result).to be true
    end

    it 'returns false when token does not exist' do
      result = described_class.revoke('nonexistent-token')

      expect(result).to be false
    end
  end
end
