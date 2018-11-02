require 'spec_helper'
require 'rails_helper'
require 'json'
include Rails.application.routes.url_helpers

RSpec.describe Game, type: :model do

  context 'associations', :r5 do
    it { is_expected.to have_many(:games_users).inverse_of(:game).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:games_users) }
    it { is_expected.to have_many(:starting_cards).through(:games_users) }
  end

  context 'enums', :r5 do
    it { is_expected.to define_enum_for(:status) }
    it { is_expected.to define_enum_for(:game_type) }

    # replace above r5 (aka version 3.0.3) 'enums' with shoulda_version_4 'enums'
    xcontext 'enums', :shoulda_version_4 do
      it { is_expected.to define_enum_for(:status).with_values([:pregame, :midgame, :postgame]).with_suffix(:game) }
      it { is_expected.to define_enum_for(:game_type).with_values([:public, :private]) }
    end
  end

  context 'db schema', :r5 do
    it { is_expected.to have_db_column(:game_type).of_type(:integer).with_options(default: :public) }
    it { is_expected.to have_db_column(:status).of_type(:integer).with_options(default: :pregame) }
    it { is_expected.to have_db_column(:join_code).of_type(:string) }
    it { is_expected.to have_db_column(:deleted_at).of_type(:datetime).with_options(null: true) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:passing_order).of_type(:string).with_options(default: '') }
    it { is_expected.to have_db_column(:description_first).of_type(:boolean).with_options(default: true) }
  end


  context FactoryBot, :r5, clean_as_group: true do
    context 'factory.create(:pregame)' do
      shared_examples 'a pregame' do |*args|
        it 'is valid' do
          pregame = described_class.create(*args)
          users = pregame.users

          expect(pregame.pregame?).to eq true
          expect(pregame.midgame?).to eq false
          expect(pregame.postgame?).to eq false
          expect(pregame.passing_order).to eq ''
          expect(pregame.join_code).to match(/[A-Z]{4}/)
          expect(pregame.description_first).to eq true
          expect(pregame.valid?).to eq true
          expect(pregame.cards).to be_blank
          expect(users.length).to eq 3

          gus = pregame.games_users
          expect(gus.length).to eq 3
          gus.each do |gu|
            expect(gu.users_game_name).to eq nil
            expect(gu.set_complete).to eq false
            expect(gu.starting_card).to eq nil
          end
        end
      end

      context 'a private pregame' do
        it_behaves_like 'a pregame', :pregame, :public_game, callback_wanted: :pregame

        it 'is valid' do
          public_pregame = FactoryBot.build_stubbed(:pregame, :public_game, callback_wanted: :pregame)
          expect(public_pregame.public_game?).to eq true
        end
      end

      context 'a private pregame'do
        it_behaves_like 'a pregame', :pregame, :private_game, callback_wanted: :pregame

        it 'is valid' do
          private_pregame = FactoryBot.build_stubbed(:pregame, :private_game, callback_wanted: :pregame)
          expect(private_pregame.private_game?).to eq true
        end
      end
    end

    context 'factory.create(:midgame_with_no_moves)' do
      shared_examples 'a midgame_with_no_moves' do |*args|
        it 'is valid' do
          midgame_with_no_moves = described_class.create(*args)
          users = midgame_with_no_moves.users

          expect(midgame_with_no_moves.pregame?).to eq false
          expect(midgame_with_no_moves.midgame?).to eq true
          expect( JSON.parse(midgame_with_no_moves.passing_order) ).to match_array(users.pluck(:id))
          expect(midgame_with_no_moves.postgame?).to eq false
          expect(midgame_with_no_moves.valid?).to eq true
          expect(midgame_with_no_moves.join_code).to be_nil
          expect(midgame_with_no_moves.description_first?).to eq true
          expect(midgame_with_no_moves.cards.length).to eq 3

          gus = midgame_with_no_moves.games_users
          expect(gus.length).to eq 3
          gus.map(&:starting_card).each do |starting_card|
            expect(starting_card.description_text).to eq nil
            expect(starting_card.description?).to eq true
            expect(starting_card.child_card).to eq nil
            expect(starting_card.placeholder).to eq true
          end

          expect(users.length).to eq 3
          expect(users.map(&:current_games_user_name)).to all(be_a String)
        end
      end

      # FactoryBot.create(:midgame_with_no_moves, :public_game, callback_wanted: :midgame_with_no_moves)
      context 'a public midgame_with_no_moves' do
        include_examples 'a midgame_with_no_moves', :midgame_with_no_moves, :public_game, callback_wanted: :midgame_with_no_moves

        it 'is valid' do
          public_midgame_with_no_moves = FactoryBot.build_stubbed(:midgame_with_no_moves, :public_game, callback_wanted: :midgame_with_no_moves)
          expect(public_midgame_with_no_moves.public_game?).to eq true
        end
      end

      # FactoryBot.create(:midgame_with_no_moves, :private_game, callback_wanted: :midgame_with_no_moves)
      context 'a private midgame_with_no_moves' do
        include_examples 'a midgame_with_no_moves', :midgame_with_no_moves, :private_game, callback_wanted: :midgame_with_no_moves

        it 'is valid' do
          private_midgame_with_no_moves = FactoryBot.build_stubbed(:midgame_with_no_moves, :private_game, callback_wanted: :midgame_with_no_moves)
          expect(private_midgame_with_no_moves.private_game?).to eq true
        end
      end
    end

    context 'factory.create(:midgame)' do
      shared_examples 'a midgame' do |*args|
        it 'is valid' do
          midgame = described_class.create(*args)
          users = midgame.users
          gus = midgame.games_users

          expect( JSON.parse(midgame.passing_order) ).to match_array users.pluck(:id)
          expect(midgame.valid?).to eq true
          expect(midgame.join_code).to be_nil
          expect(midgame.description_first?).to eq true
          expect(midgame.pregame?).to eq false
          expect(midgame.midgame?).to eq true
          expect(midgame.cards.length).to eq 7
          expect(gus.length).to eq 3

          # Deck From user_1 has submitted a starting description and has one drawing placeholder
          gu1 = gus[0]
          gu1_starting_card = gu1.starting_card
          expect(gu1_starting_card.description_text).to be_a String
          expect(gu1_starting_card.description?).to eq true
          expect(gu1_starting_card.placeholder).to eq false

          expect(gu1_starting_card.child_card).to be_a Card
          expect(gu1_starting_card.child_card.description_text).to eq nil
          expect(gu1_starting_card.child_card.drawing?).to eq true
          expect(gu1_starting_card.child_card.drawing.attached?).to eq false
          expect(gu1_starting_card.child_card.placeholder).to eq true

          expect(gu1_starting_card.child_card.child_card).to eq nil

          # Deck From user_2 has submitted a starting description and has one drawing placeholder
          gu2 = gus[1]
          gu2_starting_card = gu2.starting_card
          expect(gu2_starting_card.description_text).to be_a String
          expect(gu2_starting_card.description?).to eq true
          expect(gu2_starting_card.placeholder).to eq false

          expect(gu2_starting_card.child_card).to be_a Card
          expect(gu2_starting_card.child_card.description_text).to eq nil
          expect(gu2_starting_card.child_card.drawing?).to eq true
          expect(gu2_starting_card.child_card.drawing.attached?).to eq false
          expect(gu2_starting_card.child_card.placeholder).to eq true

          expect(gu2_starting_card.child_card.child_card).to eq nil

          # Deck from user_3 has 3 cards, 1 submitted description(user_3), 1 submitted drawing(user_1), 1 description placeholder(user_2)
          gu3 = gus[2]
          gu3_starting_card = gu3.starting_card
          expect(gu3_starting_card.description_text).to be_a String
          expect(gu3_starting_card.description?).to eq true
          expect(gu3_starting_card.placeholder).to eq false

          expect(gu3_starting_card.child_card).to be_a Card
          expect(gu3_starting_card.child_card.description_text).to eq nil
          expect(gu3_starting_card.child_card.drawing?).to eq true
          expect(gu3_starting_card.child_card.drawing.attached?).to eq true
          expect(gu3_starting_card.child_card.placeholder).to eq false

          expect(gu3_starting_card.child_card.child_card).to be_a Card
          expect(gu3_starting_card.child_card.child_card.description_text).to eq nil
          expect(gu3_starting_card.child_card.child_card.description?).to eq true
          expect(gu3_starting_card.child_card.child_card.child_card).to eq nil
          expect(gu3_starting_card.child_card.child_card.placeholder).to eq true

          expect(users.length).to eq 3
          expect(users.map(&:current_games_user_name)).to all(be_a String)
        end
      end

      context 'a public midgame' do
        it_behaves_like 'a midgame', :midgame, :public_game, callback_wanted: :midgame

        it 'is valid' do
          public_pregame = FactoryBot.build_stubbed(:midgame, :public_game, callback_wanted: :midgame)
          expect(public_pregame.public_game?).to eq true
        end
      end

      context 'a private midgame' do
        it_behaves_like 'a midgame', :midgame, :private_game, callback_wanted: :midgame

        it 'is valid' do
          private_midgame = FactoryBot.build_stubbed(:midgame, :private_game, callback_wanted: :midgame)
          expect(private_midgame.private_game?).to eq true
        end
      end
    end

    context 'postgame' do
      shared_examples 'a postgame' do |*args|
        it 'is a valid postgame' do
          postgame = described_class.create(*args)

          gus = postgame.games_users

          expect(postgame.valid?).to eq true
          expect(postgame.join_code).to be_nil
          expect(postgame.description_first?).to eq true
          expect(postgame.postgame?).to eq true
          expect(postgame.cards.length).to eq 9
          expect(gus.length).to eq 3

          gus.each do |gu|
            expect(gu.users_game_name).to be_a String
            expect(gu.set_complete).to eq true

            starting_card = gu.starting_card
            expect(starting_card.description_text).to be_a String
            expect(starting_card.description?).to eq true
            expect(starting_card.child_card).to be_a Card
            expect(starting_card.placeholder).to eq false

            expect(starting_card.child_card.description_text).to eq nil
            expect(starting_card.child_card.drawing?).to eq true
            expect(starting_card.child_card.drawing.attached?).to eq true
            expect(starting_card.child_card.child_card).to be_a Card
            expect(starting_card.child_card.placeholder).to eq false

            expect(starting_card.child_card.child_card.description_text).to be_a String
            expect(starting_card.child_card.child_card.description?).to eq true
            expect(starting_card.child_card.child_card.child_card).to eq nil
            expect(starting_card.child_card.child_card.placeholder).to eq false
          end

          users = postgame.users
          expect( JSON.parse(postgame.passing_order) ).to match_array users.pluck(:id)
          expect(postgame.users.length).to eq 3
        end
      end

      context 'a public postgame' do
        it_behaves_like 'a postgame', :postgame, :public_game, callback_wanted: :postgame

        it 'is valid' do
          public_postgame = FactoryBot.build_stubbed(:postgame, :public_game, callback_wanted: :postgame)
          expect(public_postgame.public_game?).to eq true
        end

      end

      context 'a private postgame' do
        it_behaves_like 'a postgame', :postgame, :private_game, callback_wanted: :postgame

        it 'is valid' do
          private_postgame = FactoryBot.build_stubbed(:postgame, :private_game, callback_wanted: :postgame)
          expect(private_postgame.private_game?).to eq true
        end
      end
    end
  end

  # def rendezousing_games_users
  # def unassociated_rendezousing_games_users
  # def users_game_names
  # def self.all_users_game_names join_code
  # def parse_passing_order
  # def self.start_game join_code
  # def start_game
  # def lobby_a_new_user user_id
  # def commit_a_lobbyed_user user_id, users_game_name=''
  # def remove_player user_id
  # cards_from_finished_game

  context 'methods'  do
    it '.random_public_game', :r5 do
      g1 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
      g2 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
      FactoryBot.create(:midgame, callback_wanted: :midgame)
      FactoryBot.create(:postgame, callback_wanted: :postgame)

      3.times { expect(Game.random_public_game).to be_in [g1, g2] }
    end

    it '#cards', :r5  do
      game = FactoryBot.create(:midgame, callback_wanted: :midgame)

      FactoryBot.create(:drawing, :out_of_game_card_upload)
      FactoryBot.create(:midgame, callback_wanted: :midgame)
      FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
      FactoryBot.create(:postgame, :public_game, callback_wanted: :postgame)

      expect(game.cards).to match_array Card.where(starting_games_user: game.games_user_ids)
    end



    context '#remove_player' do
      context 'does nothing and returns false if' do
        it 'user does not exist', :no_travis do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.remove_player invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user not associated with game' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          random_user = FactoryBot.create(:user)

          user_ids = game.users.ids
          random_user_id = random_user.id

          expect(game.remove_player random_user_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end
      end

      context 'if other users are rendezvouing' do
        it 'removes only the user' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user_ids = game.users.ids
          valid_id = user_ids.first

          expect(game.remove_player valid_id).to eq true
          game.reload
          expect(game.users.ids).to eq user_ids.last(2)
        end
      end

      context 'if NO other users are rendezvouing' do
        it 'removes the user and the game' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user = game.users.first
          game.users.where.not(id: user.id).destroy_all


          expect(game.remove_player user.id).to eq true
          expect(user.current_game).to eq nil
          expect(game.destroyed?).to eq true
        end
      end
    end







    context '#get_status_for_users' do
      def get_drawing_url card
        rails_blob_path(card.drawing, disposition: 'attachment')
      end


     # 4 statuses possible
      # user drawing card
      # user creating description
      # user passing is now done and
      # *) is waiting for friends to finish - aka status: finished
      # *) all other players are already finished - aka gameover
      context 'successful; A midgame.', :r5 do
        it 'midgame_with_no_moves' do
          game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
          user_1, user_2, user_3 = game.users.order(id: :asc)

          expected_response = { statuses: [ {
                                              attention_users: [user_1.id],
                                              user_status: 'working_on_card'
                                            },
                                            {
                                              attention_users: [user_2.id],
                                              user_status: 'working_on_card'
                                            },

                                            {
                                              attention_users: [user_3.id],
                                              user_status: 'working_on_card'
                                            }
                                ]
                              }

          expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
        end

        context 'Round 1' do
          it 'Move 1 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'waiting'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                user_status: 'working_on_card'
                                              },

                                              {
                                                attention_users: [user_3.id],
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 2 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'waiting'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_2.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              },

                                              {
                                                attention_users: [user_3.id],
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 3 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 3)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_1.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_2.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              },

                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_3.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end
        end

        context 'Round 2' do
          it 'Move 1 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'waiting'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_2.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              },

                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_3.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 2 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 2)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'waiting'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_2.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'description',
                                                                  description_text: Card.get_placeholder_card(user_3.id, game).parent_card.description_text
                                                                },
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 3 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 3)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_1.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_2.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_3.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end
        end

        context 'Round 3' do
          it 'Move 1 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 1)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user
            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'finished'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_2.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              },
                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_3.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 2 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { statuses: [ {
                                                attention_users: [user_1.id],
                                                user_status: 'finished'
                                              },
                                              {
                                                attention_users: [user_2.id],
                                                user_status: 'finished'
                                              },
                                              {
                                                attention_users: [user_3.id],
                                                previous_card: {
                                                                  medium: 'drawing',
                                                                  drawing_url: get_drawing_url( Card.get_placeholder_card(user_3.id, game).parent_card )
                                                                },
                                                user_status: 'working_on_card'
                                              }
                                  ]
                                }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          end

          it 'Move 3 statuses for everyone' do
            game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 3)
            gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            expected_response = { game_over: { redirect_url: game_path(game.id) } }

            expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
            expect( game.get_status_for_users([user_1, user_2]) ).to eq expected_response
            expect( game.get_status_for_users([user_1]) ).to eq expected_response
          end
        end
        it 'Move 3 statuses for everyone' do
          game = FactoryBot.create(:postgame, callback_wanted: :postgame)
          gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
          user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

          expected_response = { game_over: { redirect_url: game_path(game.id) } }

          expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
          expect( game.get_status_for_users([user_1, user_2]) ).to eq expected_response
          expect( game.get_status_for_users([user_1]) ).to eq expected_response
        end
      end

      context 'unsuccessful; NOT a midgame' do
        it 'game is a pregame' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          current_user = game.users.first

          expect( game.get_status_for_user(current_user) ).to eq false
        end

        it 'game is a postgame' do
          game = FactoryBot.create(:postgame, callback_wanted: :postgame)
          current_user = game.users.first

          expect( game.get_status_for_user(current_user) ).to eq false
        end
      end
    end

    xcontext '#rendezousing_games_users' do
      it do
        gu = FactoryBot.create(:games_user)
        FactoryBot.create(:games_user)
      end
    end

    xcontext '#lobby_a_new_user' do
      context 'does nothing and returns false if' do
        it 'user doesnt exist' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)
          #
          expect(game.lobby_a_new_user invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user is already associated with game' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user_ids = game.users.ids
          repeated_id = user_ids.first

          expect(game.lobby_a_new_user repeated_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'player playing another game' do
          user_associated_game = FactoryBot.create(:midgame, callback_wanted: :midgame)
          new_game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user = user_associated_game.users.last

          user_associated_game_user_ids = user_associated_game.users.ids
          new_game_user_ids = new_game.users.ids

          expect(new_game.lobby_a_new_user user.id).to eq false
          new_game.reload
          expect(new_game.users.ids).to eq new_game_user_ids
          expect(user_associated_game.users.ids).to eq user_associated_game_user_ids
        end

        it 'the game is not in pregame mode' do
          new_game = FactoryBot.create(:midgame, callback_wanted: :midgame)
          user = FactoryBot.create(:user)

          new_game_user_ids = new_game.users.ids

          expect(new_game.lobby_a_new_user user.id).to eq false
          new_game.reload
          expect(new_game.users.ids).to eq new_game_user_ids
        end
      end

      context 'creates a GamesUser association from game to the new player' do
        it 'when a user is rendezvouing with a new game and isnt currently playing one' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user = FactoryBot.create(:user)
          game_user_ids = game.users.ids

          expect(game.lobby_a_new_user user.id).to eq true
          game.reload
          expect(game.users.ids).to eq game_user_ids + [user.id]
        end
      end
    end

    xcontext '#commit_a_lobbyed_user', working: true do
      context 'does nothing and returns false if' do
        it 'user is not associated with the game already' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user =  FactoryBot.create(:user)
          users_game_name = 'NameName'

          expect(game.commit_a_lobbyed_user user.id, users_game_name).to eq false

          game.reload
          expect(user.users_game_name).to eq nil
        end

        it "the game's status != pregame" do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user =  FactoryBot.create(:user)
          users_game_name = 'NameName'

          game.lobby_a_new_user user.id

          game.update(status: 'midgame', join_code: nil)
          expect(game.commit_a_lobbyed_user user.id, users_game_name).to eq false

          game.reload
          expect(user.users_game_name).to eq nil
        end
      end

      context "assigns the user's game name to games_users.users_game_name if" do
        it 'associated user id and name string is received' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          user =  FactoryBot.create(:user)
          users_game_name = 'NameName'

          game.lobby_a_new_user user.id

          expect(game.commit_a_lobbyed_user user.id, users_game_name).to eq true

          game.reload
          expect(user.users_game_name).to eq users_game_name
        end
      end
    end

    xcontext '#next_player_after', working: true do
      it 'returns Empty relation if user not in game' do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        invalid_id = game.users.last.id + 1

        expect(game.send(:next_player_after, invalid_id)).to eq User.none
      end

      it 'returns the next user' do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        users = game.users.order(:id)

        expect(game.send(:next_player_after, users.first.id)).to eq users.second
        expect(game.send(:next_player_after, users.second.id)).to eq users.third
        expect(game.send(:next_player_after, users.third.id)).to eq users.first
      end
    end

    context '#set_up_next_players_turn', :r5 do

      context 'can set up a normal next drawing' do

        it 'with NO placeholder waiting for current user' do

          game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)

          gu_1 = game.games_users.order(id: :asc).first
          users = game.users.order(:id)

          # simulate user upload... round: 1, move: 1 without the next placeholder
            gu_1.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)

          expect{game.set_up_next_players_turn gu_1.starting_card}.to change{gu_1.cards.length}.from(1).to(2)
          placeholder_created = gu_1.starting_card.child_card

          gu_1.reload
          game.reload
          expect(gu_1.set_complete).to eq false
          expect(placeholder_created.uploader).to eq users[1]# see if there is a valid placeholder for the next person
          expect(placeholder_created.drawing?).to eq true
          expect(placeholder_created.placeholder).to eq true
          expect(placeholder_created.drawing.attached?).to eq false
          expect(game.midgame?).to eq true
        end

        it 'with 1 placeholder waiting for current user' do
          game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1)
          users = game.users.order(:id)
          games_users = game.games_users.order(:id)
          gu_2 = games_users[1]
          user_2 = gu_2.user

          # simulate user upload ... round:1 move:2 without the new placeholder
            gu_2.starting_card.update(description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false)


          expect{game.set_up_next_players_turn gu_2.starting_card}.to change{gu_2.cards.length}.from(1).to(2)
          placeholder_created = gu_2.starting_card.child_card

          gu_2.reload
          game.reload
          expect(gu_2.set_complete).to eq false
          expect(placeholder_created.uploader).to eq users[2]# see if there is a valid placeholder for the next person
          expect(placeholder_created.drawing?).to eq true
          expect(placeholder_created.placeholder).to eq true
          expect(placeholder_created.drawing.attached?).to eq false
          expect(game.midgame?).to eq true
        end
      end

      context 'can set up a normal next description' do
        it 'with NO placeholder waiting for current user' do

          game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 3)

          gu_3 = game.games_users.order(id: :asc)[2]
          users = game.users.order(:id)
          current_user = users.first

          # simulate user upload... round: 2, move: 1 without the next placeholder
            gu_3.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                                     content_type: 'image/jpg', \
                                                     filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
            gu_3.starting_card.child_card.update(placeholder: false);

          expect{game.set_up_next_players_turn gu_3.starting_card.child_card}.to change{gu_3.cards.length}.from(2).to(3)
          placeholder_created = gu_3.starting_card.child_card.child_card

          gu_3.reload
          game.reload
          expect(gu_3.set_complete).to eq false
          expect(placeholder_created.uploader).to eq users[1]# see if there is a valid placeholder for the next person
          expect(placeholder_created.description?).to eq true
          expect(placeholder_created.description_text).to be_nil
          expect(placeholder_created.placeholder).to eq true
          expect(placeholder_created.drawing.attached?).to eq false
          expect(game.midgame?).to eq true
        end

        it 'with 1 placeholder waiting for current user' do
          game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1)
          users = game.users.order(:id)
          games_users = game.games_users.order(:id)
          gu_1 = games_users[0]
          user_2 = users[1]

          # simulate user upload ... round:2 move:2 without the new placeholder
            gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                                     content_type: 'image/jpg', \
                                                     filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
            gu_1.starting_card.child_card.update(placeholder: false);


          expect{game.set_up_next_players_turn gu_1.starting_card.child_card}.to change{gu_1.cards.length}.from(2).to(3)
          placeholder_created = gu_1.starting_card.child_card.child_card

          gu_1.reload
          game.reload
          expect(gu_1.set_complete).to eq false
          expect(placeholder_created.uploader).to eq users[2]# see if there is a valid placeholder for the next person
          expect(placeholder_created.description?).to eq true
          expect(placeholder_created.description_text).to be_nil
          expect(placeholder_created.placeholder).to eq true
          expect(placeholder_created.drawing.attached?).to eq false
          expect(game.midgame?).to eq true
        end
      end

      it 'current card finished the set, but other sets are not finished. Not Game Over' do
        game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 3)
        games_users = game.games_users.order(:id)
        gu_2 = games_users[1]
        users = game.users.order(:id)

        # simulate user upload ... round:3 move:1 without the new placeholder
          gu_2.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )

        last_uploaded_card = gu_2.starting_card.child_card.child_card
        expect{game.set_up_next_players_turn last_uploaded_card }.not_to change{gu_2.cards.length}

        gu_2.reload
        game.reload
        expect(gu_2.set_complete).to eq true
        expect(gu_2.cards.pluck(:placeholder).any?).to eq false
        expect(game.midgame?).to eq true
      end

      it 'current card finished the last set and finished the game. Game Over' do
        game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2)
        games_users = game.games_users.order(:id)
        gu_1 = games_users[0]
        users = game.users.order(:id)

        # simulate user upload ... round:3 move:1 without the new placeholder
        gu_1.starting_card.child_card.child_card.update( description_text: TokenPhrase.generate(' ', numbers: false), placeholder: false )

        last_uploaded_card = gu_1.starting_card.child_card.child_card
        expect{game.set_up_next_players_turn last_uploaded_card }.not_to change{gu_1.cards.length}

        gu_1.reload
        game.reload
        expect(gu_1.set_complete).to eq true
        expect(gu_1.cards.pluck(:placeholder).any?).to eq false
        expect(game.postgame?).to eq true

        expect(games_users.pluck(:set_complete).all?).to eq true
      end
    end

    xcontext '#upload_info_into_placeholder_card' do
      context 'does nothing and returns false if', todo: true do
        it 'user does not exist'
        it 'placeholder_card '
      end

      context 'succeeds if', working: true do
        xit 'updating drawing' do
          # get rid of the dropbox shit

          # expect_any_instance_of(Card).to receive(:parse_and_save_uri_for_drawing).once.and_call_original

          game = FactoryBot.create(:midgame_with_no_moves, description_first: false, callback_wanted: :midgame_with_no_moves)
          gu = game.games_users.order(:id).first
          current_user = gu.user
          card_to_update = game.create_initial_placeholder_if_one_does_not_exist current_user.id
          fake_file_data = "data:image/png;base64,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"
          fake_file_name = 'file_name'

          card_returned = game.upload_info_into_placeholder_card( current_user.id, { 'filename' => fake_file_name,  'data' => fake_file_data })

          expect(card_returned.uploader_id).to eq current_user.id
          expect(card_returned.starting_games_user_id).to eq gu.id
          expect(card_returned.description_text).to eq nil
          expect(card_returned.medium).to eq 'drawing'
          expect(card_returned.drawing_file_name).to eq fake_file_name
          expect(card_returned.drawing_file_size).not_to eq nil
        end

        it 'updating description' do
          game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)

          gu = game.games_users.order(:id).first
          current_user = gu.user
          card_to_update = game.create_initial_placeholder_if_one_does_not_exist current_user.id
          sample_description_text = "Suicidal Penguin"

          card_returned = game.upload_info_into_placeholder_card( current_user.id, { 'description_text' => sample_description_text } )

          expect(card_returned.uploader_id).to eq current_user.id
          expect(card_returned.starting_games_user_id).to eq gu.id
          expect(card_returned.description_text).to eq sample_description_text
          expect(card_returned.medium).to eq 'description'
          expect(card_returned.drawing_file_name).to eq nil
          expect(card_returned.drawing_file_size).to eq nil
        end
      end
    end

    context '#create_initial_placeholder_if_one_does_not_exist', :r5 do
      context 'starts game for a user by creating their initial' do
        it 'description placeholder card' do
          gu = FactoryBot.create :games_user
          game = gu.game
          user = gu.user
          card = gu.game.create_initial_placeholder_if_one_does_not_exist user.id

          expect(card.medium).to eq 'description'
          expect(card.description_text).to eq nil
          expect(card.drawing.attached?).to eq false
          expect(card.uploader_id).to eq user.id
          expect(card.idea_catalyst_id).to eq gu.id
          expect(card.starting_games_user.id).to eq gu.id
          expect(card.parent_card).to eq nil
          expect(card.placeholder).to eq true

          expect(gu.set_complete).to eq false
          expect(gu.user_id).to eq user.id
          expect(gu.game_id).to eq game.id
          expect(gu.starting_card.id).to eq card.id
        end
      end

      context 'description placeholder card exists already' do
        it 'should not do anything' do
          game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
          gu = game.games_users.first
          user = gu.user
          card = game.create_initial_placeholder_if_one_does_not_exist gu.user_id

          expect(gu.starting_card.child_card).to eq nil
        end
      end
    end

    xcontext '#create_subsequent_placeholder_for_next_player', working: true do
      context 'creates a placeholder card for the next player to be able to go' do
        it 'description placeholder card' do
          game = FactoryBot.create(:midgame_with_no_moves, description_first: false, callback_wanted: :midgame_with_no_moves)

          user = game.users.order(:id).first
          gu = user.current_games_user

          gu.starting_card = FactoryBot.create(:drawing, uploader_id: user.id, starting_games_user: gu)
          prev_card = gu.starting_card

          card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

          expect(card.medium).to eq 'description'
          expect(card.description_text).to eq nil
          expect(card.drawing_file_name).to eq nil
          expect(card.uploader_id).to eq user.id
          expect(card.idea_catalyst_id).to eq nil
          expect(card.starting_games_user.id).to eq gu.id
          expect(card.parent_card.id).to eq prev_card.id


          expect(gu.set_complete).to eq false
          expect(gu.user_id).to eq user.id
          expect(gu.game_id).to eq game.id
          expect(gu.starting_card.child_card.id).to eq card.id
        end

        it 'drawing placeholder card' do
          game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)

          user = game.users.order(:id).first
          gu = user.current_games_user
          gu.starting_card = FactoryBot.create(:description, uploader_id: user.id, starting_games_user: gu)
          prev_card = gu.starting_card

          card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

          expect(card.medium).to eq 'drawing'
          expect(card.description_text).to eq nil
          expect(card.drawing_file_name).to eq nil
          expect(card.uploader_id).to eq user.id
          expect(card.idea_catalyst_id).to eq nil
          expect(card.starting_games_user.id).to eq gu.id
          expect(card.parent_card.id).to eq prev_card.id


          expect(gu.set_complete).to eq false
          expect(gu.user_id).to eq user.id
          expect(gu.game_id).to eq game.id
          expect(gu.starting_card.child_card.id).to eq card.id
        end
      end
    end


    context 'PRIVATE #parse_passing_order', :r5 do
      it 'parses passing order' do
        game = FactoryBot.create(:midgame, callback_wanted: :midgame)

        expect(game.send(:parse_passing_order)).to match_array game.users.ids
      end
    end
  end
end
