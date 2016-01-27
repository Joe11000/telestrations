FactoryGirl.define do

  factory :game do
    factory :active_open_game do
      is_private false
    end

    factory :post_game do
      is_active false

      after(:create) do |game|
        3.times do
          game.users << create(:user)
        end

        user1, user2, user3 = game.users
        gu1, gu2, gu3 = GamesUser.where(game_id: game, user_id: [ user1.id, user2.id, user3.id ])


        gu1.starting_card = FactoryGirl.create(:description, uploader_id: user1.id, idea_catalyst_id: user1.id)
        gu1.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user2.id)
        gu1.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user3.id)

        gu2.starting_card = FactoryGirl.create(:description, uploader_id: user2.id, idea_catalyst_id: user2.id)
        gu2.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id)
        gu2.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user3.id)

        gu3.starting_card = FactoryGirl.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id)
        gu3.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id)
        gu3.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user2.id)
      end
    end
  end


  factory :user do
    name { Faker::Name.name }
    provider { rand(2) == 0 ? 'twitter' : 'facebook' }
    uid { rand(1000..100000)}

    factory :user_w_uploaded_photo do
      provider_avatar_override_file_name { Faker::Avatar.image }
    end
  end


  factory :games_user do
    user
    game
    users_game_name { Faker::Name.name }
  end

  factory :card do
    factory :drawing do
      drawing_file_name { Faker::Avatar.image }
    end

    factory :description do
      description_text { Faker::Lorem.sentence(3)}
    end
  end
end
