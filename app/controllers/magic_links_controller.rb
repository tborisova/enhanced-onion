class MagicLinksController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user && !user.suspended
      user.generate_login_token!
      UserMailer.magic_link(user).deliver_later
      render json: { success: true }
    elsif user&.suspended
      render json: { success: false }
    else
      password = Devise.friendly_token
      email = params[:email]
      name = params[:name].presence || 'Test'
      plan = Plan.first

      user =
        User.new password:, password_confirmation: password, name:, email: email, plan_id: plan.id, missing_name: true

      if user.valid?
        user.save
        user.generate_login_token!
        UserMailer.magic_link(user).deliver_later
        render json: { success: true }
      else
        render json: { success: false }
      end
    end
  end
end
