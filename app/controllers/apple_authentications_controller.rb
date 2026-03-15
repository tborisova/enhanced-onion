class AppleAuthenticationsController < ApplicationController
  def create
    identity_token = params[:identity_token]

    unless identity_token.present?
      return render json: { token: nil, error: 'Identity token required', name: nil, email: nil }, status: :bad_request
    end

    verification = AppleAuthService.new(identity_token: identity_token).verify

    unless verification.success?
      Rails.logger.error("Apple auth failed: #{verification.error}")
      return render json: { token: nil, error: verification.error, name: nil, email: nil }, status: :unauthorized
    end

    apple_user_id = verification.user_id
    verified_email = verification.email

    user = User.find_for_apple(verified_email, apple_user_id)

    if user&.suspended
      render json: { token: nil, error: 'User suspended', name: nil, email: nil }
    else
      password = Devise.friendly_token

      show_intro = user.blank?
      user ||= User.create!(
        password:,
        password_confirmation: password,
        name: params[:name].presence || 'Apple user',
        email: verified_email || "#{apple_user_id.split('.')[0]}@curryuser.com",
        apple_idx: apple_user_id,
        plan_id: (Plan.find_by(is_free: false) || Plan.first).id
      )

      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      @current_user = user
      render json: { token: token[0], error: nil, name: user.name, email: user.email, show_intro: }
    end
  end
end
