module Web
  class RegistrationsController < ActionController::Base
    layout 'web'

    def new
    end

    def create
      password = Devise.friendly_token
      email = params[:email].to_s.strip.downcase
      name = params[:name].presence || 'Test'
      plan = Plan.first

      user = User.new(
        email: email,
        name: name,
        password: password,
        password_confirmation: password,
        plan_id: plan&.id
      )

      if user.save
        session[:web_user_id] = user.id
        redirect_to web_recipes_path, notice: 'Welcome! Your account is ready.'
      else
        flash.now[:alert] = user.errors.full_messages.join(', ')
        @email = email
        @name = name
        render :new, status: :unprocessable_entity
      end
    end
  end
end
