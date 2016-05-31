FactoryGirl.define do

  factory :card, aliases: [:description] do
    drawing_or_description "description"
    description_text { Faker::Lorem.sentence(3)}
    association :uploader, :factory => :user
    association :starting_games_user, :factory => :games_user


    factory :users_starting_description_card do
      association :idea_catalyst, :factory => :games_user
    end

    factory :drawing do
      drawing_file_name { Faker::Avatar.image }
      drawing_or_description 'drawing'
      description_text nil

      factory :users_starting_drawing_card do
        association :idea_catalyst, :factory => :games_user
      end
    end

  end
end
