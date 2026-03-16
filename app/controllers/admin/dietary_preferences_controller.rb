module Admin
  class DietaryPreferencesController < BaseController
    def index
      @pagy, @dietary_preferences = pagy(:offset, DietaryPreference.order(:name), limit: 25)
    end

    def new
      @dietary_preference = DietaryPreference.new
    end

    def create
      @dietary_preference = DietaryPreference.new(dietary_preference_params)
      if @dietary_preference.save
        redirect_to admin_dietary_preferences_path, notice: 'Dietary preference created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @dietary_preference = DietaryPreference.find(params[:id])
      @dietary_preference.destroy
      redirect_to admin_dietary_preferences_path, notice: 'Dietary preference deleted.'
    end

    private

    def dietary_preference_params
      params.require(:dietary_preference).permit(:name)
    end
  end
end
