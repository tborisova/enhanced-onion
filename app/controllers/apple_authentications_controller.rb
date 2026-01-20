class AppleAuthenticationsController < ApplicationController
  def create
    user = User.find_for_apple(params[:email], params[:apple_idx])
    password = Devise.friendly_token

    if user&.suspended
      render json: { token: nil, error: 'User suspended', name: nil, email: nil }
    else
      user ||= User.create!(
        password:,
        password_confirmation: password,
        name: params[:name].presence || 'Apple user',
        email: params[:email] || "#{params[:apple_idx].split('.')[0]}@curryuser.com",
        apple_idx: params[:apple_idx],
        plan_id: (Plan.find_by(is_free: false) || Plan.first).id
      )

      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      @current_user = user
      render json: { token: token[0], error: nil, name: user.name, email: user.email }
    end
  end
end
