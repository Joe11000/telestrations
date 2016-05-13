FactoryGirl.define do

  factory :game do
    factory :public_pre_game do
      is_private false

      after(:create) do |game|
        add_users_to game
      end
    end

    # midway through game
    factory :full_game do
      status 'midgame'
      after(:create) do |game|
        mid_game_associations game
        game.update(join_code: nil)
      end
    end

    factory :post_game do
      status 'postgame'

      after(:create) do |game|
        mid_game_associations game
        game.join_code nil
      end
    end
  end
end

def mid_game_associations game
  add_users_to game

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

def add_users_to game
  3.times { game.users << create(:user) }
end
