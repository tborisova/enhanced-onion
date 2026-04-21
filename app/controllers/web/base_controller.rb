module Web
  class BaseController < ActionController::Base
    include Pagy::Method

    before_action :authenticate_user!

    layout 'web'

    private

    def authenticate_user!
      @current_user = User.find_by(id: session[:web_user_id], suspended: false)

      if @current_user.nil?
        redirect_to sign_in_path, alert: 'Please log in.'
      end
    end
  end
end
