module Web
  class AppleAuthenticationsController < ActionController::Base
    layout 'web'
    skip_forgery_protection

    def create
      identity_token = params[:id_token]

      if identity_token.blank?
        redirect_to web_login_path, alert: 'Apple sign-in failed: missing token.' and return
      end

      audience = Rails.application.credentials.dig(:apple, :web_client_id)
      verification = AppleAuthService.new(identity_token: identity_token, expected_audience: audience).verify

      unless verification.success?
        Rails.logger.error("Apple web auth failed: #{verification.error}")
        redirect_to web_login_path, alert: 'Apple sign-in failed.' and return
      end

      apple_user_id = verification.user_id
      verified_email = verification.email

      # Apple sends `user` JSON only on the first authorization. Parse name if present.
      name_from_apple =
        begin
          data = params[:user].present? ? JSON.parse(params[:user]) : {}
          [data.dig('name', 'firstName'), data.dig('name', 'lastName')].compact.join(' ').presence
        rescue JSON::ParserError
          nil
        end

      user = User.find_for_apple(verified_email, apple_user_id)

      if user&.suspended
        redirect_to web_login_path, alert: 'Account suspended.' and return
      end

      if user.nil?
        password = Devise.friendly_token
        plan = Plan.find_by(is_free: false) || Plan.find_by(name: 'Standard plan') || Plan.first
        user = User.create!(
          password: password,
          password_confirmation: password,
          name: name_from_apple || 'Apple user',
          email: verified_email || "#{apple_user_id.split('.').first}@curryuser.com",
          apple_idx: apple_user_id,
          plan_id: plan&.id
        )
      elsif user.apple_idx.blank?
        user.update(apple_idx: apple_user_id)
      end

      session[:web_user_id] = user.id
      redirect_to web_recipes_path, notice: 'Signed in with Apple.'
    end
  end
end
