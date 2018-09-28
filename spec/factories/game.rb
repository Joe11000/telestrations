FactoryBot.define do

  # default game is private 3 person game with drawing first
  factory :game do
    description_first { true }
    game_type { 'private'}

    transient do
      num_of_players { 3 }
      callback_wanted { 'none' }
    end

    trait :public_game do
      game_type { 'public'}
    end

    trait :private_game do
      game_type { 'private' }
    end

    factory :pregame do
      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :pregame
          game.users << FactoryBot.create_list(:user, evaluator.num_of_players)
        end
      end
    end

    factory :midgame_with_no_moves do
      status { 'midgame' }

      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :midgame_with_no_moves
          new_game_associations game

          game.update(passing_order: game.user_ids.to_s, join_code: nil)
        end
      end
    end

    # midway through game
    factory :midgame do

      status { 'midgame' }

      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :midgame
          new_game_associations game
          additional_player_moves game

          game.update(passing_order: game.user_ids.to_s, join_code: nil)
        end
      end
    end

    factory :postgame do

      status { 'postgame' }

      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :postgame
          new_game_associations game
          additional_player_moves game
          complete_the_game_associations game
          game.update(passing_order: game.user_ids.to_s, join_code: nil)
        end
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

  gu1.starting_card = FactoryBot.create(:description, :placeholder, uploader_id: user1.id, idea_catalyst_id: gu1.id, starting_games_user: gu1)
  gu2.starting_card = FactoryBot.create(:description, :placeholder, uploader_id: user2.id, idea_catalyst_id: gu2.id, starting_games_user: gu2)
  gu3.starting_card = FactoryBot.create(:description, :placeholder, uploader_id: user3.id, idea_catalyst_id: gu3.id, starting_games_user: gu3)
end

def additional_player_moves game
  gu1, gu2, gu3 = game.games_users.order(id: :asc)

  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user
  # No Moves for user 1...He is still thinking about what to make user2 draw

  # user 2 passed their first card
  gu2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false))
  gu2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user3, starting_games_user: gu2)

  # user 3 passed their first card and second card
  gu3.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false))
  gu3.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user1, starting_games_user: gu3)
  gu3.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: user2, starting_games_user: gu3)
end

# this finishes the game that additional_player_moves() started
def complete_the_game_associations game
  gu1, gu2, gu3 = game.games_users.order(id: :asc)
  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user

  gu1.starting_card.update( description_text: TokenPhrase.generate(' ', numbers: false) )
  gu1.starting_card.child_card            = FactoryBot.create(:drawing,     uploader: user2, starting_games_user: gu1)
  gu1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu1)
  gu1.update(set_complete: true)

  # user 2 is on their last card
  gu2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                             content_type: 'image/jpg', \
                                             filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
  gu2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu2)
  gu2.update(set_complete: true)

  byebug
  # user 3 is on their last card
  gu3.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false) )
  gu3.update(set_complete: true)
end


