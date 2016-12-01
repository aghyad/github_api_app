require 'faker'

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    encrypted_password '45734secretrthyer3475347'
    uid '12345'
    provider 'github'
  end
end
