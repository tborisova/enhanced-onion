class RegistrationsController < ApplicationController
  include Devise::Controllers::Helpers
  skip_before_action :authenticate_user!

  def create
    password = params[:password]
    email = params[:email]
    name = params[:name]

    if password != params[:password_confirmation]
      return render json: {token: nil, error: "Passwords don't match"}
    end

    user = User.new password:, password_confirmation: password, name:, email: email

    if user.valid?
      user.save
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      p 'IN HERE'
      render json: { token: token[0], error: nil }, status: :ok
    else
      p 'IN HEREFF'
      render json: { token: nil, error: user.errors.full_messages.join(', ') }, status: :ok
    end
  end
end
