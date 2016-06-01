FactoryGirl.define do

  factory :game do
    description_first true

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

  gu1, gu2, gu3 = GamesUser.where(game_id: game.id, user_id: [ user1.id, user2.id, user3.id ])

  # player 1 is making a move
  gu1.starting_card = FactoryGirl.create(:description, uploader_id: user1.id, idea_catalyst_id: user1.id, description_text: nil, starting_games_user: gu1) # description placeholder card

  # player 3 is making a move
  gu2.starting_card = FactoryGirl.create(:description, uploader_id: user2.id, idea_catalyst_id: user2.id, starting_games_user: gu2)
  gu2.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user3.id, drawing: nil, starting_games_user: gu2) # drawing placeholder card


  # gu3.starting_card = FactoryGirl.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id)
  # gu3.starting_card.starting_games_user = gu3
  # gu3.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id)
  # gu3.starting_card.child_card.starting_games_user = gu3
  # gu3.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user2.id)
  # gu3.starting_card.child_card.child_card.starting_games_user = gu3
  # gu3.update(set_complete: true)

  game.update(passing_order: game.users.ids.to_s)
end


def postgame_associations game
  user1 = create(:user, name: "game_#{game.id}_user_with_description_placeholder")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3 = create(:user, name: "game_#{game.id}_user_completed_card_set")

  gu1 = FactoryGirl.create(:games_user, game_id: game.id, user_id: user1.id, set_complete: true)
  gu2 = FactoryGirl.create(:games_user, game_id: game.id, user_id: user2.id, set_complete: true)
  gu3 = FactoryGirl.create(:games_user, game_id: game.id, user_id: user3.id, set_complete: true)

  gu1.starting_card = FactoryGirl.create(:description, uploader_id: user1.id, starting_games_user: gu1)
  gu1.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user2.id, starting_games_user: gu1)
  gu1.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user3.id, starting_games_user: gu1)

  gu2.starting_card = FactoryGirl.create(:description, uploader_id: user2.id, idea_catalyst_id: user2.id, starting_games_user: gu2)
  gu2.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user3.id, starting_games_user: gu2)
  gu2.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user1.id, starting_games_user: gu2)

  gu3.starting_card = FactoryGirl.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id, starting_games_user: gu3)
  gu3.starting_card.child_card = FactoryGirl.create(:drawing, uploader_id: user1.id, starting_games_user: gu3)
  gu3.starting_card.child_card.child_card = FactoryGirl.create(:description, uploader_id: user2.id, starting_games_user: gu3)

  game.update(passing_order: game.users.ids.to_s)
end
