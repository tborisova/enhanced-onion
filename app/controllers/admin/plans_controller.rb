module Admin
  class PlansController < BaseController
    def index
      @pagy, @plans = pagy(:offset, Plan.order(:name), limit: 25)
    end

    def new
      @plan = Plan.new
    end

    def create
      @plan = Plan.new(plan_params)
      if @plan.save
        redirect_to admin_plans_path, notice: 'Plan created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @plan = Plan.find(params[:id])
    end

    def update
      @plan = Plan.find(params[:id])
      if @plan.update(plan_params)
        redirect_to admin_plans_path, notice: 'Plan updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @plan = Plan.find(params[:id])
      @plan.destroy
      redirect_to admin_plans_path, notice: 'Plan deleted.'
    end

    private

    def plan_params
      params.require(:plan).permit(:name, :is_free, :images_quota, :recipes_quota, :price)
    end
  end
end
