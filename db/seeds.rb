# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

%w[salt pepper eggs tomato potato cheese rice onion].each do |ingredient|
  Ingredient.create! name: ingredient
end

%w[breakfast lunch dinner salad dessert].each do |category|
  Category.create! name: category
end

%w[meat vegetarian vegan].each do |preference|
  DietaryPreference.create! name: preference
end

plan = Plan.create! name: 'Test', is_free: true

u1 = User.create! plan: plan, name: 'Llama', email: 'llama@example.com', password: 'Test1234',
                  password_confirmation: 'Test1234'
u2 = User.create! plan: plan, name: 'Test', email: 'test@example.com', password: 'Test1234',
                  password_confirmation: 'Test1234'

recipe = u1.recipes.create! title: 'Test', description: 'Mix everything well'
recipe.photo.attach(
  io: File.open(Rails.root.join('spec', 'fixtures', 'logo.png')),
  filename: 'logo.png',
  content_type: 'image/png'
)

u1.recipes.create! title: 'Test 2', description: 'Mix everything well'

1.upto(200).each do |x|
  r = u1.recipes.create! title: 'Test', description: 'Mix everything well',
                         dietary_preference_id: DietaryPreference.pluck(:id).sample

  RecipeCategory.create! recipe_id: r.id, category_id: Category.pluck(:id).sample

  RecipeIngredient.create! recipe_id: r.id, ingredient_id: Ingredient.pluck(:id).sample, quantity: "#{x} pcs"
end
