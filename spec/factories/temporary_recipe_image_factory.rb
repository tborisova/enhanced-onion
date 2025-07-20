FactoryBot.define do
  factory :temporary_recipe_image do
    after(:build) do |temporary_recipe_image|
      temporary_recipe_image.image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'logo.png')),
        filename: 'logo.png',
        content_type: 'image/png'
      )
    end
  end
end
