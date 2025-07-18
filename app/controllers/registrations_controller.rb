class RegistrationsController < ApplicationController
  include Devise::Controllers::Helpers

  def create
    password = Devise.friendly_token
    email = params[:email]
    name = params[:name]

    user = User.new password:, password_confirmation: password, name:, email: email

    if user.valid?
      user.save
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      render json: { token: token[0], error: nil, email: user.email, name: user.name }, status: :ok
    else
      render json: { token: nil, error: user.errors.full_messages.join(', '), email: nil, name: nil }, status: :ok
    end
  end
end
