module Web
  class SessionsController < ActionController::Base
    layout 'web'

    APPLE_WEB_CLIENT_ID = 'com.curryonmars.web'
    APPLE_WEB_REDIRECT_URI = 'https://app.curryonmars.com/web/apple/callback'
    APPLE_STATE_TTL = 10.minutes

    skip_before_action :verify_authenticity_token, only: [:apple_callback]
    before_action :redirect_if_authenticated, only: [:new, :create, :callback]

    def new
      @apple_sign_in_enabled = apple_sign_in_enabled?
      @apple_client_id = APPLE_WEB_CLIENT_ID
      @apple_redirect_uri = APPLE_WEB_REDIRECT_URI
      @apple_state = generate_apple_state if @apple_sign_in_enabled
    end

    def create
      user = User.find_by(email: params[:email], suspended: false)

      if user
        user.generate_login_token!
        WebMailer.magic_link(user).deliver_later
      end

      redirect_to web_login_path, notice: 'If that email is registered, a login link has been sent.'
    end

    def callback
      user = User.find_by(login_token: params[:token], suspended: false)

      if user&.login_token_valid?
        user.clear_login_token!
        session[:web_user_id] = user.id
        redirect_to web_recipes_path, notice: 'Logged in successfully.'
      else
        redirect_to web_login_path, alert: 'Invalid or expired link.'
      end
    end

    def apple_callback
      return redirect_to web_login_path, alert: 'Apple sign in is not available.' unless apple_sign_in_enabled?

      unless verify_apple_state(params[:state])
        return redirect_to web_login_path, alert: 'Sign in request expired. Please try again.'
      end

      identity_token = params[:id_token]
      return redirect_to web_login_path, alert: 'Missing identity token.' if identity_token.blank?

      verification = AppleAuthService.new(
        identity_token: identity_token,
        expected_audience: APPLE_WEB_CLIENT_ID
      ).verify

      unless verification.success?
        Rails.logger.error("Apple web auth failed: #{verification.error}")
        return redirect_to web_login_path, alert: 'Apple sign in failed.'
      end

      user = find_or_create_apple_user(verification, params[:user])

      if user.suspended
        redirect_to web_login_path, alert: 'Account is suspended.'
      else
        session[:web_user_id] = user.id
        redirect_to web_recipes_path, notice: 'Logged in successfully.'
      end
    end

    def destroy
      session.delete(:web_user_id)
      redirect_to web_login_path, notice: 'Logged out.'
    end

    private

    def redirect_if_authenticated
      if User.exists?(id: session[:web_user_id], suspended: false)
        redirect_to web_recipes_path
      end
    end

    def apple_sign_in_enabled?
      Rails.env.production?
    end

    def generate_apple_state
      Rails.application.message_verifier(:apple_web_state).generate(
        SecureRandom.hex(16),
        expires_in: APPLE_STATE_TTL
      )
    end

    def verify_apple_state(state)
      return false if state.blank?

      Rails.application.message_verifier(:apple_web_state).verify(state)
      true
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      false
    end

    def find_or_create_apple_user(verification, user_param)
      apple_user_id = verification.user_id
      verified_email = verification.email
      user = User.find_for_apple(verified_email, apple_user_id)
      return user if user

      password = Devise.friendly_token
      name = extract_apple_name(user_param) || 'Apple user'
      plan = Plan.find_by(is_free: false) || Plan.find_by_name('Standard plan')

      User.create!(
        password:,
        password_confirmation: password,
        name:,
        email: verified_email || "#{apple_user_id.split('.')[0]}@curryuser.com",
        apple_idx: apple_user_id,
        plan_id: plan.id
      )
    end

    def extract_apple_name(user_param)
      return nil if user_param.blank?

      parsed = JSON.parse(user_param)
      [parsed.dig('name', 'firstName'), parsed.dig('name', 'lastName')].compact.join(' ').presence
    rescue JSON::ParserError
      nil
    end
  end
end
