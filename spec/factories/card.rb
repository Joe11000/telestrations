FactoryBot.define do

  factory :card do
    transient do
      custom { false }
    end

    association :starting_games_user, factory: :games_user

    factory :description do
      medium { "description" }
      description_text { TokenPhrase.generate(' ', numbers: false) }

      trait :placeholder do
        description_text { nil }
        placeholder { true }
      end

      after(:build) do |card, evaluator|
        card.uploader ||= card.starting_games_user.user
      end
    end

    factory :drawing do
      medium { "drawing" }

      after(:build) do |card|
        card.uploader ||= card.starting_games_user.user

        card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'fixtures', 'files', 'images', 'thumbnail_selfy.jpg')), \
                            content_type: 'image/jpg', \
                            filename: 'provider_avatar.jpg')
      end

      trait :placeholder do
        placeholder { true }
        description_text { nil }

        after(:create) do |card|
          card.drawing.detach
        end
      end
    end
  end
end
