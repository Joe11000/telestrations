FactoryGirl.define do

  factory :game do
    factory :active_open_game do
      is_private false
    end

    factory :full_game do

      # factory :post_game do
      #   is_active false
      #   allow_additional_players false
      # end

      after(:create) do |game|
        3.times { game.users << create(:user) }

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
end
