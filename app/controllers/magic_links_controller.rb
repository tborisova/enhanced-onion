class MagicLinksController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user && !user.suspended
      user.generate_login_token!
      UserMailer.magic_link(user).deliver_later
    elsif user&.suspended
      # Don't reveal that user is suspended - same response as success
    else
      password = Devise.friendly_token
      email = params[:email]
      name = params[:name].presence || 'User'
      plan = Plan.find_by(is_free: false) || Plan.first

      user =
        User.new password:, password_confirmation: password, name:, email: email, plan_id: plan.id, missing_name: true

      if user.valid?
        user.save
        user.generate_login_token!
        UserMailer.magic_link(user).deliver_later
      end
      # Invalid email format - don't reveal, same response
    end

    # Always return success to prevent user enumeration
    render json: { success: true }
  end
end
