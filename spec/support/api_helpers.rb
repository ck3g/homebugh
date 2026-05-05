module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  def auth_headers(user)
    session = create(:auth_session, user: user, expired_at: 90.days.from_now)
    { "Authorization" => "Bearer #{session.token}" }
  end
end

RSpec.configure do |config|
  config.include ApiHelpers, type: :request
end
