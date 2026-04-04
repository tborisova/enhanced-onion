module Web
  class SessionsController < ActionController::Base
    layout 'web'

    def new
    end

    def create
      user = User.find_by(email: params[:email], suspended: false)

      if user
        user.generate_login_token!
        WebMailer.magic_link(user).deliver_later
      end

      redirect_to web_login_path, notice: 'If that email is registered, a login link has been sent.'
    end

    def callback
      user = User.find_by(login_token: params[:token], suspended: false)

      if user&.login_token_valid?
        user.clear_login_token!
        session[:web_user_id] = user.id
        redirect_to web_recipes_path, notice: 'Logged in successfully.'
      else
        redirect_to web_login_path, alert: 'Invalid or expired link.'
      end
    end

    def destroy
      session.delete(:web_user_id)
      redirect_to web_login_path, notice: 'Logged out.'
    end
  end
end
