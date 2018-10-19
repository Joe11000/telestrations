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
  game.reload

  [gu1.starting_card, gu2.starting_card, gu3.starting_card].map(&:placeholder)
end

def additional_player_moves game
    # User 1 is waiting,
    # User 2 has 2 placeholder cards. His current one he is drawing, his second one he has to describe
    # User 3 has 1 placeholder card he is drawing
    #                         u1                               Sets of Cards
    #                       v    ^            gu_1                gu_2                gu_3
    #                      v      ^           ------------------------------------------------------------
    #                     v        ^          u1_desc            u2_desc              u3_desc
    #                    v          ^         u2_draw_placeholdr u3_draw_placeholdr   u1_drawn
    #                u2  >>>>>>>>>>>>  u3     --                 -                    u2_desc_placeholdr
    #
    #
    #                                                           User Actions (go diagonal top left to bottom right)
    #                                          User_1                 User_2                   User_3
    #                                          ----------------------------------------------------------
    #                                          gu1_c1_desc            gu2_c1_desc              gu3_c1_desc
    #                                          gu3_c2_draw_placeholdr gu1_c2_draw_placeholdr   gu2_c2_draw_placeholdr
    #                                          -                      gu3_c3_desc_placeholdr   -
    #
    #                                          backloged placeholders
    #                                          -------------------------
    #                                          u1 - 0
    #                                          u2 - 2 (gu1_c2, then gu3_c2)
    #                                          u3 - 1 (gu2_c2)
  gu1, gu2, gu3 = game.games_users.order(id: :asc)

  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user

  # all users write description
  gu1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
  gu2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
  gu3.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)

  # user 2 has gu1 placeholder
  # user 3 has gu2 placeholder
  # user 1 has gu3 drawing

  gu1.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user2, starting_games_user: gu1)
  gu2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user3, starting_games_user: gu2)
  gu3.starting_card.child_card  = FactoryBot.create(:drawing,               uploader: user1, starting_games_user: gu3)

  # user 2 has gu3 placeholder
  gu3.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: user2, starting_games_user: gu3)
  game.reload
end

# this finishes the game that additional_player_moves() started
def complete_the_game_associations game
  gu1, gu2, gu3 = game.games_users.order(id: :asc)
  user1 = gu1.user
  user2 = gu2.user
  user3 = gu3.user

  gu1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                             content_type: 'image/jpg', \
                                             filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
  gu1.starting_card.child_card.update(placeholder: false);

  gu1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user3, starting_games_user: gu1)
  gu1.update(set_complete: true)
  # user 2 is on their last card
  gu2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                             content_type: 'image/jpg', \
                                             filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
  gu2.starting_card.child_card.update(placeholder: false);
  gu2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user1, starting_games_user: gu2)
  gu2.update(set_complete: true)


  # user 3 is on their last card
  gu3.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
  gu3.update(set_complete: true)
  game.reload
end


