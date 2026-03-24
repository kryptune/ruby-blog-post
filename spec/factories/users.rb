FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "username#{n}" }

    password { "Password1" }
    password_confirmation { "Password1" }
    terms { true }
    email_verified { true }

    # Optional: auto-generate a verification token if your model requires it
    verification_token { SecureRandom.hex(20) }
  end
end