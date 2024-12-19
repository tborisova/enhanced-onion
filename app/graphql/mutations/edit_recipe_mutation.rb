module Mutations
  class EditRecipeMutation < BaseMutation
    argument :recipe_id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [String], required: false
    argument :dietary_preference, String, required: false

    field :recipe, Types::RecipeType, null: true

    def resolve(input)
      recipe = GlobalID::Locator.locate(id)

      return {recipe: nil} if recipe.user_id != context[:current_user].id

      if input[:url]
        recipe.update url: input[:url]
      elsif input[:photo_id]
        photo = TemporaryRecipeImage.find input[:photo_id]
        recipe.photo.attach(photo.image.blob)
      end

      recipe.update description: input[:description] if input[:description]

      category_names =  input[:categories].map(&:downcase).map(&:strip)
      known_categories = Category.where(name: category_names).pluck :name
      missing = category_names - known_categories

      Category.insert_all missing.map {{name: _1}} if missing.present?

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
