FactoryBot.define do
  factory :recipe do
    title { 'Pumpkin soup' }
    user

    trait :with_photo do
      after(:build) do |recipe|
        recipe.photo.attach(
          io: File.open(Rails.root.join('spec', 'fixtures', 'logo.png')),
          filename: 'logo.png',
          content_type: 'image/png'
        )
      end
    end
  end
end
