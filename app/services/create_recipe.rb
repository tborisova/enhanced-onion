module CreateRecipe
  extend self

  def execute(arguments, user)
    recipe =
      Recipe.create!(title: arguments[:title], user_id: user.id, description: arguments[:description])

    if arguments[:url] && arguments[:url] =~ URI::regexp
      recipe.update url: arguments[:url]
    end

    if arguments[:photo_id]
      photo = TemporaryRecipeImage.find arguments[:photo_id]
      recipe.photo.attach(photo.image.blob)
    end

    if arguments[:categories]
      categories = GlobalID::Locator.locate_many(arguments[:categories]).pluck :id

      RecipeCategory.insert_all categories.map { {recipe_id: recipe.id, category_id: _1 } }
    end

    if arguments[:ingredients]
      ingredient_names = arguments[:ingredients].map { _1[:name] }.map(&:downcase).map(&:strip)
      known_ingredients = Ingredient.where(name: ingredient_names)
      missing = ingredient_names - known_ingredients.pluck(:name)
      ingredients = known_ingredients.index_by(&:name).transform_values { _1.id }

      if missing.present?
        result = Ingredient.insert_all missing.map {{name: _1}}, returning: %i(id name)
        ingredients = ingredients.merge result.rows.to_h.invert
      end

      to_insert = []
      arguments[:ingredients].each do |row|
        ingredient_id = ingredients[row[:name].downcase.strip]
        to_insert << {recipe_id: recipe.id, ingredient_id: ingredient_id, quantity: row[:quantity] }
      end

      RecipeIngredient.insert_all to_insert
    end

    if arguments[:dietary_preference]
      dietary_preference = DietaryPreference.find_by(name: arguments[:dietary_preference].downcase)
      recipe.update! dietary_preference_id: dietary_preference.id
    end

    recipe
  end
end
