# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

CategoryType.create(name: 'income')
CategoryType.create(name: 'spending')

Currency.create(name: "USD", unit: "$")
Currency.create(name: "EUR", unit: "€")

User.create(email: "user@example.com", password: "password", confirmed_at: Time.current)
User.create(email: "demo@homebugh.info", password: "demouser", confirmed_at: Time.current, demo_user: true)
