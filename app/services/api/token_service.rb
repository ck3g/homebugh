module Api
  class TokenService
    TOKEN_LIFETIME = 90.days

    def self.authenticate(email, password)
      user = User.find_by(email: email)
      return unless user
      return unless user.confirmed_at.present?
      return unless user.valid_password?(password)

      AuthSession.create!(
        user: user,
        token: SecureRandom.uuid,
        expired_at: TOKEN_LIFETIME.from_now
      )
    end

    def self.find_user_by_token(token)
      session = AuthSession.find_by(token: token)
      return unless session
      return unless session.expired_at > Time.current

      session.update!(expired_at: TOKEN_LIFETIME.from_now)
      session.user
    end

    def self.revoke(token)
      session = AuthSession.find_by(token: token)
      return false unless session

      session.destroy!
      true
    end
  end
end
