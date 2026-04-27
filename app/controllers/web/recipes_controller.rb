module Web
  class RecipesController < BaseController
    ALLOWED_PHOTO_TYPES = %w[image/jpeg image/png image/webp image/heic image/heif].freeze
    MAX_PHOTO_SIZE = 10.megabytes

    ALLOWED_MODES = %w[photo manual link].freeze

    def index
      scope = @current_user.recipes
                           .includes(:categories, :dietary_preference, :recipe_ingredients, :ingredients, photo_attachment: :blob)
                           .order(created_at: :desc)

      scope = scope.where('title LIKE ?', "%#{params[:term]}%") if params[:term].present?

      scope = scope.joins(:categories).where(categories: { id: params[:category] }) if params[:category].present?

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

      redirect_to root_path, alert: 'Recipe not found.' unless @recipe
    end

    def new
      @mode = ALLOWED_MODES.include?(params[:mode]) ? params[:mode] : nil
      @categories = Category.order(:name)
      @form = default_form_values
    end

    def create
      @mode = ALLOWED_MODES.include?(params[:mode]) ? params[:mode] : nil
      @categories = Category.order(:name)

      recipe_params = params.fetch(:recipe, {}).permit(
        :title, :description, :url, :photo, :dietary_preference, :category_id,
        ingredients: %i[name quantity]
      )

      photo = recipe_params[:photo]
      if photo.present?
        unless ALLOWED_PHOTO_TYPES.include?(photo.content_type)
          return render_form_error(recipe_params, 'Invalid photo format. Use JPEG, PNG, WebP, or HEIC.')
        end

        return render_form_error(recipe_params, 'Photo is too large. Max 10 MB.') if photo.size > MAX_PHOTO_SIZE
      end

      service_input = {
        title: recipe_params[:title],
        description: recipe_params[:description],
        url: recipe_params[:url],
        photo: photo,
        categories: Array(recipe_params[:category_id]).compact_blank,
        dietary_preference: recipe_params[:dietary_preference]
      }

      if @mode == 'manual'
        service_input[:ingredients] = Array(recipe_params[:ingredients])
                                      .map { |row| { name: row[:name], quantity: row[:quantity] } }
                                      .reject { |r| r[:name].blank? }
      end

      result = CreateRecipe.execute(service_input, @current_user)

      if result.recipe
        redirect_to recipe_path(result.recipe), notice: 'Recipe saved.'
      else
        message = result.errors&.first&.dig(:message) || 'Could not save recipe.'
        render_form_error(recipe_params, message.capitalize)
      end
    end

    private

    def render_form_error(recipe_params, message)
      flash.now[:alert] = message
      @form = recipe_params.to_h.merge('photo' => nil)
      render :new, status: :unprocessable_entity
    end

    def default_form_values
      {
        'title' => nil,
        'description' => nil,
        'url' => nil,
        'category_id' => nil,
        'dietary_preference' => nil,
        'ingredients' => []
      }
    end
  end
end
