# frozen_string_literal: true

class Rack::Attack
  # Throttle magic link requests by IP
  # 5 requests per minute per IP
  throttle('magic_links/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/magic_link' && req.post?
  end

  # Throttle magic link requests by email
  # 3 requests per 15 minutes per email address
  throttle('magic_links/email', limit: 3, period: 15.minutes) do |req|
    if req.path == '/magic_link' && req.post?
      req.params['email'].to_s.downcase.strip.presence
    end
  end

  # Throttle login attempts by IP
  # 10 requests per minute per IP
  throttle('logins/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/login' && req.get?
  end

  # Throttle registration attempts by IP
  # 5 requests per minute per IP
  throttle('registrations/ip', limit: 5, period: 1.minute) do |req|
    req.ip if req.path == '/register' && req.post?
  end

  # Throttle Apple auth attempts by IP
  # 10 requests per minute per IP
  throttle('apple_auth/ip', limit: 10, period: 1.minute) do |req|
    req.ip if req.path == '/apple' && req.post?
  end

  # Throttle file uploads by user (via IP as proxy)
  # 30 uploads per minute
  throttle('uploads/ip', limit: 30, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/uploads') && req.post?
  end

  # General API throttle
  # 300 requests per minute per IP
  throttle('api/ip', limit: 300, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/graphql')
  end

  # Block suspicious requests
  blocklist('block bad IPs') do |req|
    # Add known bad IPs or patterns here
    # Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 5, findtime: 1.minute, bantime: 1.hour) do
    #   req.path == '/login' && req.post?
    # end
    false
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |request|
    retry_after = (request.env['rack.attack.match_data'] || {})[:period]
    [
      429,
      { 'Content-Type' => 'application/json', 'Retry-After' => retry_after.to_s },
      [{ error: 'Rate limit exceeded. Please retry later.' }.to_json]
    ]
  end
end
