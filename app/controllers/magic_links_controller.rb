class MagicLinksController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_login_token!
      UserMailer.magic_link(user).deliver_later
    end

    # TODO: this should return json with success - true/false and error
    head :ok
  end


  def login
    user = User.find_by(login_token: params[:token])
    if user&.login_token_valid?
      user.clear_login_token!
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)
      @current_user = user
      render json: { token: token[0], error: nil, name: user.name, email: user.email }
    else
      render json: { token: nil, error: "Invalid credentials or token expired", name: nil, email: nil }
    end
  end
end
