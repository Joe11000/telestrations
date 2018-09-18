FactoryBot.define do

  # default game is private 3 person game with drawing first
  factory :game do
    description_first { true }
    game_type { 'private'}

    transient do
      num_of_players { 3 }
    end

    trait :public_game do
      game_type { 'public'}
    end

    trait :private_game do
      game_type { 'private' }
    end


    trait :pregame do
      after(:create) do |game, evaluator|
        add_players game, evaluator
      end
    end

    trait :midgame_without_cards do
      status { 'midgame' }

      after(:create) do |game, evaluator|
        add_players game, evaluator
        game.start_game
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end

    # midway through game
    trait :midgame do

      status { 'midgame' }

      after(:create) do |game, evaluator|
        midgame_associations game, evaluator
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end

    trait :postgame do
      status { 'postgame' }

      after(:create) do |game, evaluator|
        postgame_associations game
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end
  end
end


def add_players game, evaluator
  game.users << FactoryBot.create_list(:user, evaluator.num_of_players)
end

def midgame_associations game, description_first
  user1 = create(:user, name: "game_#{game.id}_user_with_description_placeholder")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3 = create(:user, name: "game_#{game.id}_user_completed_card_set")

  game.users << user1
  game.users << user2
  game.users << user3

  # byebug
  gu1, gu2, gu3 = GamesUser.where(game_id: game.id, user_id: [ user1.id, user2.id, user3.id ])

  # byebug
  # player 1 is making a move
  gu1.starting_card = FactoryBot.create(:description, uploader_id: user1.id, idea_catalyst_id: gu1.id, description_text: nil, starting_games_user: gu1) # description placeholder card

  # byebug
  # player 3 is making a move
  gu2.starting_card = FactoryBot.create(:description, uploader_id: user2.id, idea_catalyst_id: gu2.id, starting_games_user: gu2)
  # byebug
  gu2.starting_card.child_card = FactoryBot.create(:drawing, uploader_id: user3.id, drawing: nil, starting_games_user: gu2) # drawing placeholder card
  # byebug


  # gu3.starting_card = FactoryBot.create(:description, uploader_id: user3.id, idea_catalyst_id: user3.id)
  # gu3.starting_card.starting_games_user = gu3
  # gu3.starting_card.child_card = FactoryBot.create(:drawing, uploader_id: user1.id)
  # gu3.starting_card.child_card.starting_games_user = gu3
  # gu3.starting_card.child_card.child_card = FactoryBot.create(:description, uploader_id: user2.id)
  # gu3.starting_card.child_card.child_card.starting_games_user = gu3
  # gu3.update(set_complete: true)
end


def postgame_associations game
  user1 = create(:user, name: "game_#{game.id}_user_with_description_placeholder")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3 = create(:user, name: "game_#{game.id}_user_completed_card_set")

  gu1 = FactoryBot.create(:games_user, game: game, user: user1, set_complete: true)
  gu2 = FactoryBot.create(:games_user, game: game, user: user2, set_complete: true)
  gu3 = FactoryBot.create(:games_user, game: game, user: user3, set_complete: true)

  gu1.starting_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu1, idea_catalyst: gu1)
  gu1.starting_card.child_card = FactoryBot.create(:drawing, uploader: user2, starting_games_user: gu1)
  gu1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu1)

  gu2.starting_card = FactoryBot.create(:description, uploader: user2, starting_games_user: gu2, idea_catalyst: gu2)
  gu2.starting_card.child_card = FactoryBot.create(:drawing, uploader: user3, starting_games_user: gu2)
  gu2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu2)

  gu3.starting_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu3, idea_catalyst: gu3)
  gu3.starting_card.child_card = FactoryBot.create(:drawing, uploader: user1, starting_games_user: gu3)
  gu3.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user2, starting_games_user: gu3)

  game.update(passing_order: game.user_ids.to_s)
end


