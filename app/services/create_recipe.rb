module CreateRecipe
  extend self

  Response = Data.define :recipe, :errors

  def execute(arguments, user)
    if user.plan_limits[:recipes_quota_reached] || user.plan_limits[:images_quota_reached]
      return Response.new recipe: nil, errors: nil
    end

    attributes = arguments.slice(:title, :description).merge(user_id: user.id)

    if arguments[:url].present? && arguments[:url] =~ URI::DEFAULT_PARSER.make_regexp
      attributes[:url] = arguments[:url]
    elsif arguments[:url].present?
      return Response.new recipe: nil, errors: [{ field: 'url', message: 'invalid URL' }]
    end

    recipe = Recipe.create! attributes

    if arguments[:photo_id]
      photo = TemporaryRecipeImage.find arguments[:photo_id]
      recipe.photo.attach(photo.image.blob)
    end

    if arguments[:categories]
      categories = GlobalID::Locator.locate_many(arguments[:categories]).pluck :id

      RecipeCategory.insert_all categories.map { { recipe_id: recipe.id, category_id: _1 } }
    end

    if arguments[:ingredients]
      ingredient_names = arguments[:ingredients].compact.map { _1[:name] }.map(&:downcase).map(&:strip).compact_blank

      if ingredient_names.present?
        known_ingredients = Ingredient.where(name: ingredient_names)
        missing = ingredient_names - known_ingredients.pluck(:name)
        ingredients = known_ingredients.index_by(&:name).transform_values(&:id)

        if missing.present?
          result = Ingredient.insert_all missing.map { { name: _1 } }, returning: %i[id name]
          ingredients = ingredients.merge result.rows.to_h.invert
        end

        to_insert = []
        arguments[:ingredients].each do |row|
          ingredient_id = ingredients[row[:name].downcase.strip]
          to_insert << { recipe_id: recipe.id, ingredient_id: ingredient_id, quantity: row[:quantity] }
        end

        RecipeIngredient.insert_all to_insert
      end
    end

    if arguments[:dietary_preference]
      dietary_preference = DietaryPreference.find_by(name: arguments[:dietary_preference].downcase)
      recipe.update! dietary_preference_id: dietary_preference.id
    end

    Response.new recipe:, errors: nil
  end
end
