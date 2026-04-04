module Web
  class RecipesController < BaseController
    def index
      scope = @current_user.recipes
                .includes(:categories, :dietary_preference, :recipe_ingredients, :ingredients, photo_attachment: :blob)
                .order(created_at: :desc)

      scope = scope.where("title LIKE ?", "%#{params[:term]}%") if params[:term].present?

      if params[:category].present?
        scope = scope.joins(:categories).where(categories: { id: params[:category] })
      end

      if params[:dietary_preference].present?
        scope = scope.joins(:dietary_preference).where(dietary_preferences: { id: params[:dietary_preference] })
      end

      @pagy, @recipes = pagy(scope, limit: 12)
      @categories = Category.order(:name)
      @dietary_preferences = DietaryPreference.order(:name)
    end

    def show
      @recipe = @current_user.recipes
                  .includes(:categories, :dietary_preference, recipe_ingredients: :ingredient)
                  .find_by(id: params[:id])

      redirect_to web_recipes_path, alert: 'Recipe not found.' unless @recipe
    end
  end
end
