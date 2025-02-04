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

%w(breakfast lunch dinner salad dessert).each do |category|
  Category.create! name: category
end

%w(meat vegeterian vegan).each do |preference|
  DietaryPreference.create! name: preference
end


u1 = User.create! name: 'Llama', email: 'llama@example.com', password: 'Test1234', password_confirmation: 'Test1234'
u2 = User.create! name: 'Test', email: 'test@example.com', password: 'Test1234', password_confirmation: 'Test1234'

