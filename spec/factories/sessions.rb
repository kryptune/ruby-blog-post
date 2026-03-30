FactoryBot.define do
  factory :session do
    user { nil }
    session_token { "MyString" }
    device_info { "MyString" }
    ip_address { "MyString" }
    expires_at { "" }
  end
end
