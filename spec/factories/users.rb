
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    username { Faker::Internet.username(specifier: 5..10) }
    password { "Password1" }
    password_confirmation { "Password1" }
    terms { true }
  end
end