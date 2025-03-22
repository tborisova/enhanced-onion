class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i(create)

  def create
    user = User.find_for_authentication(email: params[:email])
    if user&.valid_password?(params[:password])
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      @current_user = user
      render json: { token: token[0], error: nil, name: user.name }
    else
      render json: { token: nil, error: "Invalid credentials", name: nil }
    end
  end
end
