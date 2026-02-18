module Admin
  class BaseController < ActionController::Base
    include Pagy::Method

    before_action :authenticate_admin!

    layout 'admin'

    private

    def authenticate_admin!
      @current_user = User.find_by(id: session[:admin_user_id])

      if @current_user.nil?
        redirect_to admin_login_path, alert: 'Please log in.'
      elsif !@current_user.admin?
        session.delete(:admin_user_id)
        redirect_to admin_login_path, alert: 'Access denied.'
      end
    end
  end
end
