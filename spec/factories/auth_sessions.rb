FactoryBot.define do
  factory :auth_session do
    user
    token { SecureRandom.hex(16) }
    expired_at { 2.weeks.from_now }
  end
end
