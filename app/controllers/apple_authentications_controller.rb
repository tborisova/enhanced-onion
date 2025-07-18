class AppleAuthenticationsController < ApplicationController
  def create
    user = User.find_for_apple(params[:email], params[:apple_idx])
    password = SecureRandom.hex(8)
    user ||= User.create!(
      password:,
      password_confirmation: password,
      name: params[:name].presence || 'Apple user',
      email: params[:email],
      apple_idx: params[:apple_idx]
    )

    p user
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
    @current_user = user
    render json: { token: token[0], error: nil, name: user.name, email: user.email }
  end
end
