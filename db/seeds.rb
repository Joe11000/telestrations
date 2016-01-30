# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# u = User.create(name: 'Joe Noonan')

# u.games << Game.create


# gu = u.games_users.first

# gu.starting_card = Card.create
# # {"oauth_token"=>"JWHBuAAAAAAAjpvXAAABUikBg1o", "oauth_verifier"=>"LFKa1Bp5WxnrpamskuHrPOyHgZqf7brF", "controller"=>"sessions", "action"=>"create", "provider"=>"twitter"}


FactoryGirl.create(:full_game)
