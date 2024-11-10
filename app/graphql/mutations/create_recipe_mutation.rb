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

      known_categories = Category.where(name: input[:categories]).pluck :name
      missing = input[:categories] - known_categories

      if missing.present?
        Category.insert_all missing.map {{name: _1}}
      end

      recipe.categories << Category.where(name: input[:categories])


      {recipe:}
    end
  end
end
