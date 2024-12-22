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
      category_names = arguments[:categories].map(&:downcase).map(&:strip)
      recipe.
        recipe_categories.joins(:category).
        where.not(categories: {name: category_names}).delete_all

      categories = Category.create_if_missing(category_names)
      to_insert = []
      categories.each do |id|
        next if recipe.categories.map(&:id).include?(id)
        to_insert << {recipe_id: recipe.id, category_id: id }
      end

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

      recipe_ingredients.where.not(ingredients: {name: arguments[:ingredients].map { _1[:name].downcase.strip } }).delete_all
    end

    recipe.save
    recipe
  end
end
