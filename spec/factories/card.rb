FactoryBot.define do

  factory :card do

    association :starting_games_user, factory: :games_user

    factory :description do
      medium { "description" }
      description_text { TokenPhrase.generate(' ', numbers: false) }

      # attach
      after(:build) do |user|
        user.uploader = user.starting_games_user.user
      end

      trait :starting_card do

        after(:build) do |user|
          user.idea_catalyst = user.starting_games_user
        end
      end
    end

    factory :drawing do
      medium { "drawing" }

      after(:build) do |user|
        user.uploader = user.starting_games_user.user

        user.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                            content_type: 'image/jpg', \
                            filename: 'provider_avatar.jpg')
      end

      trait :starting_card do

        after(:build) do |user|
          user.idea_catalyst = user.starting_games_user
        end
      end

      trait :out_of_game_card_upload do
        out_of_game_card_upload { true }
      end
    end
  end
end
