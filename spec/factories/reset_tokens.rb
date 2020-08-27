FactoryBot.define do
  factory :reset_token do
    token { "MyString" }
    verification_code { 1 }
    expiration { "2020-08-27" }
    used { false }
  end
end
