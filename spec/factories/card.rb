FactoryBot.define do

  factory :card do

    association :starting_games_user, factory: :games_user

    factory :description do
      medium { "description" }
      description_text { TokenPhrase.generate(' ', numbers: false) }

      trait :placeholder do
        description_text { nil }
      end

      after(:build) do |card|
        card.uploader = card.starting_games_user.user
      end

      trait :starting_card do
        after(:build) do |card|
          card.idea_catalyst = card.starting_games_user
        end
      end
    end

    factory :drawing do
      medium { "drawing" }

      after(:build) do |card|
        card.uploader = card.starting_games_user.user

        card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                            content_type: 'image/jpg', \
                            filename: 'provider_avatar.jpg')
      end


      trait :out_of_game_card_upload do
        out_of_game_card_upload { true }
      end

      trait :starting_card do
        after(:build) do |card|
          card.idea_catalyst = card.starting_games_user
        end
      end

      trait :placeholder do
        after(:create) do |card|
          card.drawing.detach
        end
      end

    end
  end
end
