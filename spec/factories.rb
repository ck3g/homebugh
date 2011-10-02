require 'factory_girl'

Factory.define :user do |u|
  u.email "user@test.com"
  u.password "password"
end