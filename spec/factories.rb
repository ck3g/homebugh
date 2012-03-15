require 'factory_girl'

FactoryGirl.define do
  factory :user do |u|
    u.email "user@test.com"
    u.password "password"
  end
end
