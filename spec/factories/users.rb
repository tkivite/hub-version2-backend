# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    firstname { 'demo' }
    othernames { 'user' }
    gender { 'Male' }
    email { 'demouser@demo.test' }
    password { 'password' }
    mobile { '0725475051' }
    created_by { '1' }
    last_login_time { '2020-08-25 15:07:49' }
    logged_in { false }
    status { 0 }
  end
  factory :user1, class: User do
    firstname { 'demo' }
    othernames { 'user' }
    gender { 'Male' }
    email { 'demouser1@demo.test' }
    password { 'password' }
    mobile { '0725475052' }
    created_by { '1' }
    last_login_time { '2020-08-25 15:07:49' }
    logged_in { false }
    status { 0 }
  end
  factory :user2, class: User do
    firstname { 'dem2o' }
    othernames { 'user' }
    gender { 'Male' }
    email { 'demouser1@demo2.test' }
    password { 'password' }
    mobile { '0725475059' }
    created_by { '1' }
    last_login_time { '2020-08-25 15:07:49' }
    logged_in { false }
    status { 0 }
  end
end
