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
        game.users << FactoryBot.create_list(:user, evaluator.num_of_players)
      end
    end

    trait :midgame_with_no_moves do
      status { 'midgame' }

      after(:create) do |game, evaluator|
        new_game_associations game, evaluator
        game.start_game
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end

    # midway through game
    trait :midgame do

      status { 'midgame' }

      after(:create) do |game, evaluator|
        new_game_associations game
        additional_player_moves
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end


    trait :postgame do
      status { 'postgame' }

      after(:create) do |game, evaluator|
        completed_game_associations game
        game.update(passing_order: game.user_ids.to_s, join_code: nil)
      end
    end
  end
end

# these add users with their users_game_names and a placeholder starting card
def new_game_associations game
  gu1 = FactoryBot.create :games_user, game_id: game.id
  gu2 = FactoryBot.create :games_user, game_id: game.id
  gu3 = FactoryBot.create :games_user, game_id: game.id

  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user

  gu2.starting_card = FactoryBot.create(:description, uploader_id: user1.id, idea_catalyst_id: gu1.id, description_text: nil, starting_games_user: gu1)
  gu2.starting_card = FactoryBot.create(:description, uploader_id: user2.id, idea_catalyst_id: gu2.id, description_text: nil, starting_games_user: gu2)
  gu3.starting_card = FactoryBot.create(:description, uploader_id: user3.id, idea_catalyst_id: gu3.id, description_text: nil, starting_games_user: gu3 )
end

def additional_player_moves game
  gu1, gu2, gu3 = game.games_users

  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user

  user1 = create(:user, name: "game_#{game.id}_user_completed_card_set")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3.update(name: "game_#{game.id}_user_with_description_placeholder")

  byebug

  gu1.starting_card                       = FactoryBot.create(:description, uploader: user1, starting_games_user: gu1, idea_catalyst: gu1)
  gu1.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user2, starting_games_user: gu1)
  gu1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu1)

  gu2.starting_card                       = FactoryBot.create(:description, uploader: user2, starting_games_user: gu2, idea_catalyst: gu2)
  gu2.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user3, starting_games_user: gu2)
  gu2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu2, description_text: nil)

  gu3.starting_card                       = FactoryBot.create(:description, uploader: user3, starting_games_user: gu3, idea_catalyst: gu3)
  gu3.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user1, starting_games_user: gu3)
  gu3.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user2, starting_games_user: gu3, description_text: nil)

  game.update(passing_order: game.user_ids.to_s)


end


def completed_game_associations game
  user1 = create(:user, name: "game_#{game.id}_user_with_description_placeholder")
  user2 = create(:user, name: "game_#{game.id}_user_with_drawing_placeholder")
  user3 = create(:user, name: "game_#{game.id}_user_completed_card_set")

  gu1 = FactoryBot.create(:games_user, game: game, user: user1, set_complete: true)
  gu2 = FactoryBot.create(:games_user, game: game, user: user2, set_complete: true)
  gu3 = FactoryBot.create(:games_user, game: game, user: user3, set_complete: true)

  gu1.starting_card                       = FactoryBot.create(:description, uploader: user1, starting_games_user: gu1, idea_catalyst: gu1)
  gu1.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user2, starting_games_user: gu1)
  gu1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu1)

  gu2.starting_card                       = FactoryBot.create(:description, uploader: user2, starting_games_user: gu2, idea_catalyst: gu2)
  gu2.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user3, starting_games_user: gu2)
  gu2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu2)

  gu3.starting_card                       = FactoryBot.create(:description, uploader: user3, starting_games_user: gu3, idea_catalyst: gu3)
  gu3.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user1, starting_games_user: gu3)
  gu3.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user2, starting_games_user: gu3)

  game.update(passing_order: game.user_ids.to_s)
end


