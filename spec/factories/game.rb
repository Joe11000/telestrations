FactoryBot.define do

  # default game is private 3 person game with drawing first
  factory :game do
    description_first { true }
    game_type { 'private'}

    transient do
      num_of_players { 3 }
      callback_wanted { 'none' }
      round { 0 }
      move { 0 }
      with_user_ids {[]}
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
          new_game_associations game, evaluator.num_of_players, evaluator

          game.update(passing_order: game.user_ids.to_s, join_code: nil)
        end
      end
    end

    # midway through game
    factory :midgame do

      status { 'midgame' }

      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :midgame && (evaluator.round == 0 && evaluator.move == 0)
          new_game_associations game, evaluator.num_of_players, evaluator
          game.update(passing_order: game.user_ids.to_s, join_code: nil)
          ::GameWithThreePeople::additional_player_moves game


        elsif evaluator.callback_wanted == :midgame && (evaluator.round != 0 && evaluator.move != 0)
          new_game_associations game, evaluator.num_of_players, evaluator
          game.update(passing_order: game.user_ids.to_s, join_code: nil)

          case evaluator.round
            when 1
              params = game.games_users.order(id: :asc)

              if evaluator.num_of_players == 2
                round = ::GameWithTwoPeople::Round_1.new(*params)

                round.move_1! if(evaluator.move >= 1)
                round.move_2! if(evaluator.move >= 2)

              elsif evaluator.num_of_players == 3
                round = ::GameWithThreePeople::Round_1.new(*params)

                round.move_1! if(evaluator.move >= 1)
                round.move_2! if(evaluator.move >= 2)
                round.move_3! if(evaluator.move >= 3)
              end
            when 2
              params = game.games_users.order(id: :asc)
              if evaluator.num_of_players == 2
                ::GameWithTwoPeople::Round_1.new(*params).move_all!
                game.reload

                round = ::GameWithTwoPeople::Round_2.new(*params)
                round.move_1! if(evaluator.move >= 1)
                round.move_2! if(evaluator.move >= 2)

              elsif evaluator.num_of_players == 3
                ::GameWithThreePeople::Round_1.new(*params).move_all!
                game.reload

                round = ::GameWithThreePeople::Round_2.new(*params)
                round.move_1! if(evaluator.move >= 1)
                round.move_2! if(evaluator.move >= 2)
                round.move_3! if(evaluator.move >= 3)
              end
            when 3
              if evaluator.num_of_players == 3
                params = game.games_users.order(id: :asc)
                ::GameWithThreePeople::Round_1.new(*params).move_all!
                game.reload
                ::GameWithThreePeople::Round_2.new(*params).move_all!
                game.reload
                round = ::GameWithThreePeople::Round_3.new(*params)

                round.move_1! if(evaluator.move >= 1)
                round.move_2! if(evaluator.move >= 2)
                round.move_3! if(evaluator.move >= 3)
              end
          end

        end
      end
    end

    factory :postgame do

      status { 'postgame' }

      after(:create) do |game, evaluator|
        if evaluator.callback_wanted == :postgame
          new_game_associations game, evaluator.num_of_players, evaluator
          ::GameWithThreePeople::additional_player_moves game
          ::GameWithThreePeople::complete_the_game_associations game
          game.update(passing_order: game.user_ids.to_s, join_code: nil)
        end
      end
    end
  end


end

# these add users with their users_game_names and a placeholder starting card
def new_game_associations game, num_of_players, evaluator
  if evaluator.with_user_ids.present?
    evaluator.with_user_ids.each do |user_id|
      current_gu = FactoryBot.create(:games_user, game_id: game.id, user_id: user_id)
      current_gu.starting_card = FactoryBot.create(:description, :placeholder, uploader_id: current_gu.user_id, idea_catalyst_id: current_gu.id, starting_games_user_id: current_gu.id)
    end
  end

  remaining_number_of_users_to_make = num_of_players - evaluator.with_user_ids.length
  remaining_number_of_users_to_make.times do
    current_gu = FactoryBot.create(:games_user, game_id: game.id)
    current_gu.starting_card = FactoryBot.create(:description, :placeholder, uploader_id: current_gu.user_id, idea_catalyst_id: current_gu.id, starting_games_user_id: current_gu.id)
  end

  game.reload
  true
end



# class GameBuilder
#   attr_reader :round_num, :move_num, :users, :gus

#   def initialize round_num_to_reach:, move_num_to_reach:, game:
#     @round_num_to_reach = round_num_to_reach
#     @move_num_to_reach = move_num_to_reach
#     @game = game
#     @gus = game.gus.order(id: :asc)
#     @users = @gus.order(id: :asc).map(&:user)

#     @medium_order = ['description', 'drawing']

#   end

#   def result
#     for round in 1..@round_num_to_reach do

#       moves_this_round = (round == @round_num_to_reach ? @move_num_to_reach : users.length)
#       card_to_update = nil

#       for move in 1..moves_this_round do
#         card_to_update = begin
#           if card_to_update.nil?
#             @gus[move - 1].starting_card
#           else
#             card_to_update.
#           end
#         end

#         if(round == 1)
#           if description_first
#             card_to_update.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
#             card_to_update.child_card = FactoryBot.create(:drawing, :placeholder, uploader: gus[move], starting_games_user: @gus[move - 1])
#           else
#             # drawing first
#           end
#         end

#         elsif round != round_num_to_reach
#           if (@medium_order[(round + move) % 2] == 'description')
#             @gu_3.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
#                                          content_type: 'image/jpg', \
#                                          filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
#             @gu_3.starting_card.child_card.update(placeholder: false);
#           end

#         else # round == round_num_to_reach

#         end

#       end
#     end

#   end
# end

class GameWithThreePeople

  class Round_1
    def initialize gu_1, gu_2, gu_3
      @gu_1, @gu_2, @gu_3 = gu_1, gu_2, gu_3
    end

    def move_1!
      # User 1 adding a description to Deck 1
      @gu_1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
      @gu_1.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: @gu_2.user, starting_games_user: @gu_1)
    end

    def move_2!
      # User 2 adding a description to Deck 2
      @gu_2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
      @gu_2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: @gu_3.user, starting_games_user: @gu_2)
    end

    def move_3!
      # User 3 adding a description to Deck 3
      @gu_3.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
      @gu_3.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder,  uploader: @gu_1.user, starting_games_user: @gu_3)
    end

    def move_all!
      move_1!
      move_2!
      move_3!
    end
  end

  class Round_2
    def initialize gu_1, gu_2, gu_3
      @gu_1, @gu_2, @gu_3 = gu_1, gu_2, gu_3
    end

    # User 1 adding a drawing to Deck 3, then pass to User 2
    def move_1!
      @gu_3.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
      @gu_3.starting_card.child_card.update(placeholder: false);

      # create placeholder for next user
      @gu_3.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: @gu_2.user, starting_games_user: @gu_3)
    end

    # User 2 adding a drawing to Deck 1, then pass to User 3
    def move_2!
      @gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
      @gu_1.starting_card.child_card.update(placeholder: false);

      # create placeholder for next user
      @gu_1.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: @gu_3.user, starting_games_user: @gu_1)
    end

    # User 3 adding a drawing to Deck 2
    def move_3!
      @gu_2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
      @gu_2.starting_card.child_card.update(placeholder: false);

      # create placeholder for next user
      @gu_2.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: @gu_1.user, starting_games_user: @gu_2)
    end

    def move_all!
      move_1!
      move_2!
      move_3!
    end
  end

  class Round_3
    def initialize gu_1, gu_2, gu_3
      @gu_1, @gu_2, @gu_3 = gu_1, gu_2, gu_3
    end

    # User 1 adding a description to Deck 2, then passing to User 2. User 1 is finished.
    def move_1!
      @gu_2.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
      @gu_2.update(set_complete: true)
    end

    # User 1 adding a description to Deck 2, then passing to User 2. User 1 is finished.
    def move_2!
      @gu_3.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
      @gu_3.update(set_complete: true)
    end

    # User 3 adding a description to Deck 1, then passing to User 1. User 3 is finished. Game is over.
    def move_3!
      @gu_1.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
      @gu_1.update(set_complete: true)
    end

    def move_all!
      move_1!
      move_2!
      move_3!
    end
  end


  def self.additional_player_moves game
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
    #                                          gu_1_c1_desc            gu_2_c1_desc              gu_3_c1_desc
    #                                          gu_3_c2_draw_placeholdr gu_1_c2_draw_placeholdr   gu_2_c2_draw_placeholdr
    #                                          -                      gu_3_c3_desc_placeholdr   -
    #
    #                                          backloged placeholders
    #                                          -------------------------
    #                                          u1 - 0
    #                                          u2 - 2 (gu_1_c2, then gu_3_c2)
    #                                          u3 - 1 (gu_2_c2)
    gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

    user_1 = gu_1.user
    user_2 = gu_2.user
    user_3 = gu_3.user

    # all users write description
    gu_1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
    gu_2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
    gu_3.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)

    # user 2 has gu_1 placeholder
    # user 3 has gu_2 placeholder
    # user 1 has gu_3 drawing

    gu_1.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user_2, starting_games_user: gu_1)
    gu_2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user_3, starting_games_user: gu_2)
    gu_3.starting_card.child_card  = FactoryBot.create(:drawing,               uploader: user_1, starting_games_user: gu_3)

    # user 2 has gu_3 placeholder
    gu_3.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: user_2, starting_games_user: gu_3)
    game.reload
  end

  # this finishes the game that additional_player_moves() started
  def self.complete_the_game_associations game
    gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
    user_1 = gu_1.user
    user_2 = gu_2.user
    user_3 = gu_3.user

    gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
    gu_1.starting_card.child_card.update(placeholder: false);

    gu_1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user_3, starting_games_user: gu_1)
    gu_1.update(set_complete: true)
    # user 2 is on their last card
    gu_2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
    gu_2.starting_card.child_card.update(placeholder: false);
    gu_2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user_1, starting_games_user: gu_2)
    gu_2.update(set_complete: true)


    # user 3 is on their last card
    gu_3.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
    gu_3.update(set_complete: true)
    game.reload
  end
end

module GameWithTwoPeople
  class Round_1
    def initialize gu_1, gu_2
      @gu_1, @gu_2 = gu_1, gu_2
    end

    def move_1!
      # User 1 adding a description to Deck 1
      @gu_1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
      @gu_1.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: @gu_2.user, starting_games_user: @gu_1)
    end

    def move_2!
      # User 2 adding a description to Deck 2
      @gu_2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
      @gu_2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: @gu_1.user, starting_games_user: @gu_2)
    end

    def move_all!
      move_1!
      move_2!
    end
  end

  class Round_2
    def initialize gu_1, gu_2
      @gu_1, @gu_2 = gu_1, gu_2
    end

    # User 1 adding a drawing to Deck 2, then user is done
    def move_1!
      @gu_2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
      @gu_2.starting_card.child_card.update(placeholder: false);

      @gu_2.update(set_complete: true)
    end

    # User 2 adding a drawing to Deck 1, then game is done
    def move_2!
      @gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
      @gu_1.starting_card.child_card.update(placeholder: false);

      @gu_1.update(set_complete: true)
    end


    def move_all!
      move_1!
      move_2!
    end
  end



  def self.additional_player_moves game
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
    #                                          gu_1_c1_desc            gu_2_c1_desc              gu_3_c1_desc
    #                                          gu_3_c2_draw_placeholdr gu_1_c2_draw_placeholdr   gu_2_c2_draw_placeholdr
    #                                          -                      gu_3_c3_desc_placeholdr   -
    #
    #                                          backloged placeholders
    #                                          -------------------------
    #                                          u1 - 0
    #                                          u2 - 2 (gu_1_c2, then gu_3_c2)
    #                                          u3 - 1 (gu_2_c2)
    gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

    user_1 = gu_1.user
    user_2 = gu_2.user
    user_3 = gu_3.user

    # all users write description
    gu_1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
    gu_2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)
    gu_3.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)

    # user 2 has gu_1 placeholder
    # user 3 has gu_2 placeholder
    # user 1 has gu_3 drawing

    gu_1.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user_2, starting_games_user: gu_1)
    gu_2.starting_card.child_card  = FactoryBot.create(:drawing, :placeholder, uploader: user_3, starting_games_user: gu_2)
    gu_3.starting_card.child_card  = FactoryBot.create(:drawing,               uploader: user_1, starting_games_user: gu_3)

    # user 2 has gu_3 placeholder
    gu_3.starting_card.child_card.child_card = FactoryBot.create(:description, :placeholder, uploader: user_2, starting_games_user: gu_3)
    game.reload
  end

  # this finishes the game that additional_player_moves() started
  def self.complete_the_game_associations game
    gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
    user_1 = gu_1.user
    user_2 = gu_2.user
    user_3 = gu_3.user

    gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
    gu_1.starting_card.child_card.update(placeholder: false);

    gu_1.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user_3, starting_games_user: gu_1)
    gu_1.update(set_complete: true)
    # user 2 is on their last card
    gu_2.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                               content_type: 'image/jpg', \
                                               filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
    gu_2.starting_card.child_card.update(placeholder: false);
    gu_2.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: user_1, starting_games_user: gu_2)
    gu_2.update(set_complete: true)


    # user 3 is on their last card
    gu_3.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )
    gu_3.update(set_complete: true)
    game.reload
  end
end
