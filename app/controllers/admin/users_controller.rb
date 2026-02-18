module Admin
  class UsersController < BaseController
    def index
      users = User.order(created_at: :desc)
      users = users.where('email ILIKE ?', "%#{params[:search]}%") if params[:search].present?
      @pagy, @users = pagy(:offset, users, limit: 25)
      @plans = Plan.all
    end

    def show
      @user = User.find(params[:id])
      @recipes = @user.recipes.order(created_at: :desc)
    end

    def update
      @user = User.find(params[:id])

      if params[:suspend]
        @user.update!(suspended: true)
        redirect_to admin_users_path, notice: "#{@user.email} suspended."
      elsif params[:unsuspend]
        @user.update!(suspended: false)
        redirect_to admin_users_path, notice: "#{@user.email} unsuspended."
      elsif params[:plan_id]
        @user.update!(plan_id: params[:plan_id])
        redirect_to admin_users_path, notice: "Plan updated for #{@user.email}."
      else
        redirect_to admin_users_path
      end
    end
  end
end
