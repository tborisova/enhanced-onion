module EditRecipe
  extend self

  def execute(user, recipe, arguments)
    return nil unless user == recipe.user

    recipe.assign_attributes(arguments.slice(:title, :description, :url))

    if arguments[:url]
      recipe.url = arguments[:url]
    elsif arguments[:photo_id]
      photo = TemporaryRecipeImage.find arguments[:photo_id]
      recipe.photo.attach(photo.image.blob)
    end

    if arguments[:categories]
      categories = GlobalID::Locator.locate_many(arguments[:categories]).pluck :id
      recipe.recipe_categories.where.not(category_id: categories).delete_all
      to_insert = categories.map {{recipe_id: recipe.id, category_id: _1 }}
      RecipeCategory.insert_all to_insert, unique_by: %i(recipe_id category_id)
    end

    if arguments[:ingredients]
      recipe_ingredients = recipe.recipe_ingredients.joins(:ingredient)
      arguments[:ingredients].each do |ingredient|
        to_update =
          recipe_ingredients.
          detect { _1.ingredient.name == ingredient[:name].downcase.strip && _1.quantity != ingredient[:quantity] }

        skip =
          recipe_ingredients.
          detect { _1.ingredient.name == ingredient[:name].downcase.strip && _1.quantity == ingredient[:quantity] }

        next if skip

        if to_update
          to_update.update! quantity: ingredient[:quantity]
        else
          new_ingredient = Ingredient.find_or_create_by name: ingredient[:name].downcase.strip

          RecipeIngredient.create!(
            ingredient_id: new_ingredient.id, quantity: ingredient[:quantity], recipe_id: recipe.id
          )
        end
      end

      recipe_ingredients.
        where.not(ingredients: {name: arguments[:ingredients].map { _1[:name].downcase.strip } }).delete_all
    end

    if arguments[:dietary_preference]
      recipe.dietary_preference_id = DietaryPreference.find_by(name: arguments[:dietary_preference].downcase).id
    end

    recipe.save
    recipe
  end
end
