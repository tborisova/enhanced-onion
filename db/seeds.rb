# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


%w(salt pepper eggs tomato potato cheese rice onion).each do |ingredient|
  Ingredient.create! name: ingredient
end

%w(breakfast lunch dinner meat vegeterian salad dessert).each do |category|
  Category.create! name: category
end


u1 = User.create! name: 'Llama'
u2 = User.create! name: 'Test'

r1 = Recipe.create! title: 'eggs with tomatoes', user_id: u1.id
r2 = Recipe.create! title: 'Rice', user_id: u2.id

RecipeCategory.create! recipe: r1, category: Category.find_by(name: 'breakfast')
RecipeCategory.create! recipe: r1, category: Category.find_by(name: 'vegeterian')

RecipeCategory.create! recipe: r2, category: Category.find_by(name: 'vegeterian')
RecipeCategory.create! recipe: r2, category: Category.find_by(name: 'lunch')

RecipeIngredient.create! recipe: r1, ingredient: Ingredient.find_by(name: 'eggs')
RecipeIngredient.create! recipe: r1, ingredient: Ingredient.find_by(name: 'tomato')
RecipeIngredient.create! recipe: r1, ingredient: Ingredient.find_by(name: 'salt')

RecipeIngredient.create! recipe: r2, ingredient: Ingredient.find_by(name: 'onion')
RecipeIngredient.create! recipe: r2, ingredient: Ingredient.find_by(name: 'rice')
RecipeIngredient.create! recipe: r2, ingredient: Ingredient.find_by(name: 'salt')
