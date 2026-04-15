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

    def new
      @recipe = @current_user.recipes.build
      @categories = Category.order(:name)
      @dietary_preferences = DietaryPreference.order(:name)
    end

    def create
      @recipe = @current_user.recipes.build(recipe_params)

      if params[:category_ids].is_a?(Array)
        @recipe.category_ids = params[:category_ids].reject(&:blank?)
      end

      if @recipe.save
        assign_ingredients(@recipe, params[:ingredients])
        redirect_to web_recipe_path(@recipe), notice: 'Recipe added.'
      else
        @categories = Category.order(:name)
        @dietary_preferences = DietaryPreference.order(:name)
        flash.now[:alert] = @recipe.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @recipe = @current_user.recipes
                  .includes(:categories, :dietary_preference, recipe_ingredients: :ingredient)
                  .find_by(id: params[:id])

      redirect_to web_recipes_path, alert: 'Recipe not found.' unless @recipe
    end

    private

    def recipe_params
      params.permit(:title, :description, :time, :url, :photo, :dietary_preference_id)
    end

    def assign_ingredients(recipe, raw)
      return if raw.blank?

      raw.to_s.lines.each do |line|
        line = line.strip
        next if line.empty?

        name, quantity = line.split(/\s[-–—]\s|,/, 2).map { |s| s&.strip }
        next if name.blank?

        ingredient = Ingredient.find_or_create_by(name: name)
        recipe.recipe_ingredients.create(ingredient: ingredient, quantity: quantity)
      end
    end
  end
end
