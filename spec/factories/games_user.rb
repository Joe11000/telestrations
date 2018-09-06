FactoryBot.define do
  factory :games_user do
    user
    game
    users_game_name { Faker::Name.name }
  end
end
