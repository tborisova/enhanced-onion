FactoryBot.define do
  factory :user do
    name { 'John Doe' }
    email { "john#{rand(0..100)}@example.com" }
    password { 'Test1234' }
    plan
  end
end
