FactoryBot.define do

  factory :card, aliases: [:description] do
    medium { "description" }
    description_text { Faker::Lorem.sentence(3).upcase}
    association :uploader, factory: :user
    association :starting_games_user, factory: :games_user


    factory :users_starting_description_card do
      association :idea_catalyst, factory: :games_user
    end

    factory :drawing do
      drawing_file_name { Faker::Avatar.image }
      medium { 'drawing' }
      description_text { nil }

      factory :users_starting_drawing_card do
        association :idea_catalyst, :factory => :games_user
      end
    end

  end
end
