module Admin
  class SessionsController < ActionController::Base
    layout 'admin'

    def new
    end

    def create
      user = User.find_by(email: params[:email])

      if user&.admin? && !user.suspended
        user.generate_login_token!
        AdminMailer.magic_link(user).deliver_later
      end

      redirect_to admin_login_path, notice: 'If that email is registered as admin, a login link has been sent.'
    end

    def callback
      user = User.find_by(login_token: params[:token], suspended: false)

      if user&.login_token_valid? && user.admin?
        user.clear_login_token!
        session[:admin_user_id] = user.id
        redirect_to admin_users_path, notice: 'Logged in successfully.'
      else
        redirect_to admin_login_path, alert: 'Invalid or expired link.'
      end
    end

    def destroy
      session.delete(:admin_user_id)
      redirect_to admin_login_path, notice: 'Logged out.'
    end
  end
end
