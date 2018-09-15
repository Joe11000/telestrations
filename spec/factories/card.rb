FactoryBot.define do

  factory :card, aliases: [:description] do

    medium { "description" }
    description_text { TokenPhrase.generate(' ', numbers: false) }
    association :starting_games_user, factory: :games_user

    after(:build) do |user|
      user.uploader = user.starting_games_user.user
    end

    factory :users_starting_description_card do
      association :idea_catalyst, factory: :games_user

      after(:build) do |user|
        user.idea_catalyst = user.starting_games_user.user
      end
    end

    factory :drawing do

      medium { 'drawing' }

      trait :out_of_game_card_upload do
        association :starting_games_user, factory: :nil
        association :idea_catalyst, factory: :nil
      end

      factory :users_starting_drawing_card do
        association :idea_catalyst, :factory => :games_user
      end

      after(:build) do |user|
        user.provider_avatar.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg'), \
         ), content_type: 'image/jpg', filename: 'provider_avatar.jpg')
      end
    end

  end
end
