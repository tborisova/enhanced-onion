module Mutations
  class CreateRecipeMutation < BaseMutation
    argument :title, String, required: true
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [String], required: true
    argument :dietary_preference, String, required: true

    field :recipe, Types::RecipeType

    def resolve(input)
      recipe =
        Recipe.create!(
          title: input[:title],
          user: context[:current_user],
          description: input[:description]
        )

      if input[:url]
        recipe.update url: input[:url]
      elsif input[:photo_id]
        photo = TemporaryRecipeImage.find input[:photo_id]
        recipe.photo.attach(photo.image.blob)
      else
        recipe.update description: input[:description]
      end

      category_names =  input[:categories].map(&:downcase).map(&:strip)
      known_categories = Category.where(name: category_names).pluck :name
      missing = category_names - known_categories

      if missing.present?
        Category.insert_all missing.map {{name: _1}}
      end

      recipe.categories << Category.where(name: category_names)

      ingredient_names = input[:ingredients].map { _1[:name] }.map(&:downcase).map(&:strip)
      known_ingredients = Ingredient.where(name: ingredient_names).select('id, name')
      missing = ingredient_names - known_ingredients.pluck(:name)
      ingredients = known_ingredients.index_by(&:name).transform_values { _1.id }

      if missing.present?
        result = Ingredient.insert_all missing.map {{name: _1}}, returning: %i(id name)
        ingredients.merge result.rows.to_h.invert
      end

      to_insert = []
      input[:ingredients].each do |row|
        ingredient_id = ingredients[row[:name]]
        to_insert << {recipe_id: recipe.id, ingredient_id: ingredient_id, quantity: row[:quantity] }
      end

      RecipeIngredient.insert_all to_insert

      {recipe:}
    end
  end
end
