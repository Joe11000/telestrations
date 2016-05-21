FactoryGirl.define do

  factory :game do
    factory :public_pre_game do
      is_private false

      after(:create) do |game|
        add_users_to game
      end
    end

    # midway through game
    factory :midgame do
      status 'midgame'
      after(:create) do |game|
        midgame_associations game
        game.update(join_code: nil)
      end
    end

    factory :postgame do
      status 'postgame'

      after(:create) do |game|
        postgame_associations game
        game.join_code = nil
      end
    end
  end
end


def add_users_to game
end

def midgame_associations game
  user1 = create(:user, name: "game_#{game.id}_user_with_description_placeholder")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3 = create(:user, name: "game_#{game.id}_user_completed_card_set")

  game.users << user1
  game.users << user2
  game.users << user3

  gu1, gu2, gu3 = GamesUser.where(games_user_id: game, user_id: [ user1.id, user2.id, user3.id ])

  gu1.starting_card = FactoryGirl.create(:description, uploader_id: user1.id, idea_catalyst_id: user1.id, games_user_id: gu1.id, description_text: nil) # description placeholder card

  gu2.starting_card = FactoryGirl.create(:description, uploader_id: user2.id, idea_catalyst_id: user2.id, games_user_id: gu2.id)
  gu2.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user3.id, drawing: nil, games_user_id: gu2.id) # drawing placeholder card

  gu3.starting_card = FactoryGirl.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id, games_user_id: gu3.id)
  gu3.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id, games_user_id: gu3.id)
  gu3.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user2.id, games_user_id: gu3.id)

  game.update(passing_order: game.users.ids.to_s)
end


def postgame_associations game
  add_users_to game

  user1, user2, user3 = game.users
  gu1, gu2, gu3 = GamesUser.where(games_user_id: game, user_id: [ user1.id, user2.id, user3.id ])

  gu1.starting_card = FactoryGirl.create(:description, uploader_id: user1.id, idea_catalyst_id: user1.id, games_user_id: gu1.id)
  gu1.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user2.id, games_user_id: gu1.id)
  gu1.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user3.id, games_user_id: gu1.id)

  gu2.starting_card = FactoryGirl.create(:description, uploader_id: user2.id, idea_catalyst_id: user2.id, games_user_id: gu2.id)
  gu2.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user3.id, games_user_id: gu2.id)
  gu2.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user1.id, games_user_id: gu2.id)

  gu3.starting_card = FactoryGirl.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id, games_user_id: gu3.id)
  gu3.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id, games_user_id: gu3.id)
  gu3.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user2.id, games_user_id: gu3.id)

  game.update(passing_order: game.users.ids.to_s)
end
