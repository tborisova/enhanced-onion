# frozen_string_literal: true

class AppleAuthService
  class VerificationError < StandardError; end

  Result = Struct.new(:success?, :user_id, :email, :error, keyword_init: true)

  def initialize(identity_token:, expected_audience: nil)
    @identity_token = identity_token
    @expected_audience = expected_audience || Rails.application.credentials.dig(:apple, :client_id)
  end

  def verify
    id_token = AppleID::IdToken.new(@identity_token)
    id_token.verify!(
      client: apple_client,
      access_token: nil
    )

    Result.new(
      success?: true,
      user_id: id_token.sub,
      email: id_token.email,
      error: nil
    )
  rescue AppleID::IdToken::VerificationFailed => e
    Result.new(
      success?: false,
      user_id: nil,
      email: nil,
      error: "Token verification failed: #{e.message}"
    )
  rescue StandardError => e
    Result.new(
      success?: false,
      user_id: nil,
      email: nil,
      error: "Verification error: #{e.message}"
    )
  end

  private

  def apple_client
    @apple_client ||= AppleID::Client.new(
      identifier: @expected_audience,
      team_id: Rails.application.credentials.dig(:apple, :team_id),
      key_id: Rails.application.credentials.dig(:apple, :key_id),
      private_key: Rails.application.credentials.dig(:apple, :private_key)
    )
  end
end
