module Admin
  class RecipesController < BaseController
    def index
      @pagy, @recipes = pagy(:offset, Recipe.includes(:user, photo_attachment: :blob).order(created_at: :desc), limit: 25)
    end

    def show
      @recipe = Recipe.includes(:ingredients, :categories, :dietary_preference).find(params[:id])
    end

    def destroy
      @recipe = Recipe.find(params[:id])
      @recipe.destroy
      redirect_to admin_recipes_path, notice: 'Recipe deleted.'
    end
  end
end
