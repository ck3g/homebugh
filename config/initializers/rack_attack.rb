class Rack::Attack
  # Throttle API requests to 2 requests/second per IP (burst of 4)
  throttle('api/ip', limit: 4, period: 2.seconds) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Return JSON response for throttled requests
  self.throttled_responder = lambda do |_req|
    [429, { 'Content-Type' => 'application/json' }, [{ error: 'Rate limit exceeded' }.to_json]]
  end
end
