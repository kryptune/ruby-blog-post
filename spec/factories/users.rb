FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "username#{n}" }
    password { "Password1" }
    password_confirmation { "Password1" }
    terms { true }

    after(:create) do |user|
      user.update_columns(email_verified: true, verification_token: nil)
    end

    trait :unverified do
      after(:create) do |user|
        user.update_columns(email_verified: false, verification_token: "abc123")
      end
    end
  end
end