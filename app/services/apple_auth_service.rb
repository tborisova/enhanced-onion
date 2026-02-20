# frozen_string_literal: true

class AppleAuthService
  APPLE_JWKS_URL = 'https://appleid.apple.com/auth/keys'
  APPLE_ISSUER = 'https://appleid.apple.com'

  Result = Struct.new(:success?, :user_id, :email, :error, keyword_init: true)

  def initialize(identity_token:, expected_audience: nil)
    @identity_token = identity_token
    @expected_audience = expected_audience || Rails.application.credentials.dig(:apple, :client_id)
  end

  def verify
    claims = decode_and_verify!
    Result.new(success?: true, user_id: claims['sub'], email: claims['email'], error: nil)
  rescue StandardError => e
    Result.new(success?: false, user_id: nil, email: nil, error: "Token verification failed: #{e.message}")
  end

  private

  def decode_and_verify!
    jwk_set = JSON::JWK::Set.new(fetch_apple_jwks)
    claims = JSON::JWT.decode(@identity_token, jwk_set)

    raise 'Invalid issuer' unless claims['iss'] == APPLE_ISSUER
    raise 'Invalid audience' unless Array(claims['aud']).include?(@expected_audience)
    raise 'Token has expired' if claims['exp'].to_i < Time.now.to_i

    claims
  end

  def fetch_apple_jwks
    response = Faraday.get(APPLE_JWKS_URL)
    raise 'Failed to fetch Apple public keys' unless response.success?

    JSON.parse(response.body)
  end
end
