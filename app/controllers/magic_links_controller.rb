class MagicLinksController < ApplicationController

  def create
    user = User.find_by(email: params[:email])

    if user
      user.generate_login_token!
      UserMailer.magic_link(user).deliver_later
      render json: { success: true }
    else
      render json: { success: false }
    end
  end
end
