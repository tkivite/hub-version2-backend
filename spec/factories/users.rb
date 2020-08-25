FactoryBot.define do
  factory :user do
    firstname { 'demo' }
    othernames { 'user' }
    gender { 'Male' }
    email { 'demouser@demo.test' }
    password_digest { 'Thisisatestpassword' }
    mobile { '0725475051' }
    created_by { '1' }
    last_login_time { '2020-08-25 15:07:49' }
    logged_in { false }
    status { 0 }
  end
end
