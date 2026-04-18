module Admin
  class DashboardController < BaseController
    def index
      @users_count = User.count
      @recipes_count = Recipe.count
      @categories_count = Category.count
      @plans_count = Plan.count
      @dietary_preferences_count = DietaryPreference.count
      @temporary_images_count = TemporaryRecipeImage.count
    end
  end
end
