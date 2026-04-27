module CreateRecipe
  extend self

  Response = Data.define :recipe, :errors

  def execute(arguments, user)
    if user.plan_limits[:recipes_quota_reached]
      return Response.new recipe: nil, errors: [{ field: 'base', message: 'recipe quota reached' }]
    end

    has_photo = arguments[:photo_id].present? || arguments[:photo].present?
    if has_photo && user.plan_limits[:images_quota_reached]
      return Response.new recipe: nil, errors: [{ field: 'base', message: 'image quota reached' }]
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
    elsif arguments[:photo]
      recipe.photo.attach(arguments[:photo])
    end

    if arguments[:categories].present?
      category_ids = arguments[:categories].compact_blank.map(&:to_i)

      RecipeCategory.insert_all category_ids.map { { recipe_id: recipe.id, category_id: _1 } }
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
          name = row[:name].to_s.downcase.strip
          next if name.blank?

          ingredient_id = ingredients[name]
          to_insert << { recipe_id: recipe.id, ingredient_id: ingredient_id, quantity: row[:quantity] }
        end

        RecipeIngredient.insert_all to_insert if to_insert.any?
      end
    end

    if arguments[:dietary_preference].present?
      dietary_preference = DietaryPreference.find_by(name: arguments[:dietary_preference].to_s.downcase)
      recipe.update! dietary_preference_id: dietary_preference.id if dietary_preference
    end

    Response.new recipe:, errors: nil
  end
end
