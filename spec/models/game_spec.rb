require 'spec_helper'
require 'rails_helper'

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


  context 'factory', r5_wip: true do
    before :all do
      @pregame  = FactoryBot.create(:game, :pregame)
      @midgame  = FactoryBot.create(:game, :midgame)
      @postgame = FactoryBot.create(:game, :postgame)
    end

    # This can wait
    xcontext 'FactoryBot.create(:game)' do
      context 'FactoryBot.create(:game, :public_game)' do
        context 'FactoryBot.create(:game, :public_game, :pregame)' do
          context 'FactoryBot.create(:game, :public_game, :pregame, :description_first)'
          context 'FactoryBot.create(:game, :public_game, :pregame, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :public_game, :midgame)' do
          context 'FactoryBot.create(:game, :public_game, :midgame, :description_first)'
          context 'FactoryBot.create(:game, :public_game, :midgame, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :public_game, :midgame_without_cards)' do
          context 'FactoryBot.create(:game, :public_game, :midgame_without_cards, :description_first)'
          context 'FactoryBot.create(:game, :public_game, :midgame_without_cards, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :public_game, :postgame)' do
          context 'FactoryBot.create(:game, :public_game, :postgame, :description_first)'
          context 'FactoryBot.create(:game, :public_game, :postgame, :drawing_first)'
        end
      end

      context 'FactoryBot.create(:game, :private_game)' do
        context 'FactoryBot.create(:game, :private_game, :pregame)' do
          context 'FactoryBot.create(:game, :private_game, :pregame, :description_first)'
          context 'FactoryBot.create(:game, :private_game, :pregame, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :private_game, :midgame)' do
          context 'FactoryBot.create(:game, :private_game, :midgame, :description_first)'
          context 'FactoryBot.create(:game, :private_game, :midgame, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :private_game, :midgame_without_cards)' do
          context 'FactoryBot.create(:game, :private_game, :midgame_without_cards, :description_first)'
          context 'FactoryBot.create(:game, :private_game, :midgame_without_cards, :drawing_first)'
        end

        context 'FactoryBot.create(:game, :private_game, :postgame)' do
          context 'FactoryBot.create(:game, :private_game, :postgame, :description_first)'
          context 'FactoryBot.create(:game, :private_game, :postgame, :drawing_first)'
        end
      end

    end

    xcontext ':midgame' do

      it ':game is valid', :r5 do
        expect(@pregame).to be_valid
        expect(@midgame).to be_valid
        expect(@postgame).to be_valid
      end

      context ':midgame' do
        before :all do
          @midgame = FactoryBot.create(:game, :midgame)
        end

        it 'is valid' do
          expect(FactoryBot.create(:game, :midgame).valid?).to eq true
        end

        xit 'has correct associations' do
          expect(@midgame.users.count).to eq 3


          @midgame.users.each do |user|
            expect(user.starting_cards.length).to eq 1
            expect(user.starting_cards.order(:id).first.child_card.parent_card).to eq user.starting_cards.order(:id).first
          end
        end

        it 'status' do
          expect(@midgame.status).to eq 'midgame'
        end

        it 'removes join code' do
          expect(@midgame.join_code).to eq nil
        end
      end
    end

    xcontext ':postgame' do
      before :all do
        @postgame = FactoryBot.create(:game, :postgame)
      end

      it 'is valid' do
        expect(@postgame.valid?).to eq true
      end

      it 'has correct associations' do
        expect(@postgame.users.count).to eq 3

        @postgame.users.each do |user|
          expect(user.starting_cards.length).to eq 1
          expect(user.starting_cards.first.child_card.parent_card).to eq user.starting_cards.first
        end
      end

      it 'status' do
        expect(@postgame.status).to eq 'postgame'
      end

      it 'does not allow additional players' do
        expect(@postgame.join_code).to eq nil
      end
    end

    xcontext 'public_pregame' do
      before :all do
        @public_pregame = FactoryBot.create(:game, :pregame, :public_game)
      end

      it 'has 3 users attached' do
        expect(@public_pregame.users.count).to eq 3
      end

      it 'is a public game' do
        expect(@public_pregame.public_game?).to eq true
      end

      it 'allows additional players' do
        expect(@public_pregame.join_code).to match /^[a-zA-Z]{4}$/
      end

      it 'game has not been completed' do
        expect(@public_pregame.status).to eq 'pregame'
      end

      it 'game has not been deleted for some strange reason' do
        expect(@public_pregame.deleted_at).to eq nil
      end
    end
  end

  xcontext 'basic instantiation' do
    let(:game){ FactoryBot.create(:game) }

    # before(:each) do
    #   Game.delete_all
    # end

    it 'game_type is set to public_game' do
      expect(game.game_type).to eq 'true'
    end

    it 'status is defaulted to pregame' do
      expect(game.status).to eq 'pregame'
    end

    it 'a 4 digit join_code' do
      10.times{ FactoryBot.create(:game)}
      expect(Game.pluck(:join_code).length).to eq 10
    end
  end

  context 'methods', :r5_wip do
    it '#random_public_game' do
      g1 = FactoryBot.create(:game, :pregame, :public_game)
      FactoryBot.create(:game, :midgame)
      FactoryBot.create(:game, :postgame)

      3.times { expect(Game.random_public_game).to eq g1 }
    end

    it '#cards', :r5  do
      game = FactoryBot.create(:game, :midgame)

      FactoryBot.create(:drawing, :out_of_game_card_upload)
      FactoryBot.create(:game, :midgame)
      FactoryBot.create(:game, :midgame, :public_game)
      FactoryBot.create(:game, :postgame, :public_game)

      expect(game.cards).to match_array Card.where(starting_games_user: game.games_user_ids)
    end

    context '#cards_from_finished_game' do
      before(:all) do
        @game = FactoryBot.create(:game, :postgame)
        FactoryBot.create(:drawing, :out_of_game_card_upload)
        FactoryBot.create(:game, :midgame)
        FactoryBot.create(:game, :midgame, :public_game)
        FactoryBot.create(:game, :postgame, :public_game)

        @cards = @game.cards_from_finished_game
      end

      it 'returns correct ordering of cards', :r5_wip do
        first_user, second_user, third_user = @game.users
        first_user_next_card, second_user, third_user

        while()
        @game.games_users.pluck(:users_game_name)

        first_starting_card, second_starting_card, third_starting_card = @game.starting_cards

        byebug
        expect(@cards).to match_array [
                                        [
                                          [first_starting_card.uploader.users_game_name, first_starting_card ],
                                          [first_starting_card.child_card.uploader.users_game_name, first_starting_card.child_card ],
                                          [first_starting_card.child_card.child_card.uploader.users_game_name, first_starting_card.child_card.child_card ]
                                        ],
                                        [
                                          [second_starting_card.uploader.users_game_name, second_starting_card ],
                                          [second_starting_card.child_card.uploader.users_game_name, second_starting_card.child_card ],
                                          [second_starting_card.child_card.child_card.uploader.users_game_name, second_starting_card.child_card.child_card ]
                                        ],
                                        [
                                          [third_starting_card.uploader.users_game_name, third_starting_card ],
                                          [third_starting_card.child_card.uploader.users_game_name, third_starting_card.child_card ],
                                          [third_starting_card.child_card.child_card.uploader.users_game_name, third_starting_card.child_card.child_card ]
                                        ]
                                      ]

      end
    end

    xcontext '#remove_player', working: true do
      context 'does nothing and returns false if' do
        it 'user does not exist' do
          game = FactoryBot.create(:game, :pregame)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.remove_player invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user not associated with game' do
          game = FactoryBot.create(:game, :pregame)
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
          game = FactoryBot.create(:game, :pregame)
          user_ids = game.users.ids
          valid_id = user_ids.first

          expect(game.remove_player valid_id).to eq true
          game.reload
          expect(game.users.ids).to eq user_ids.last(2)
        end
      end

      context 'if NO other users are rendezvouing' do
        it 'removes the user and the game' do
          game = FactoryBot.create(:game, :pregame)
          user = game.users.first
          game.users.where.not(id: user.id).destroy_all


          expect(game.remove_player user.id).to eq true
          expect(user.current_game).to eq nil
          expect(game.destroyed?).to eq true
        end
      end
    end

    # context '#rendezvous_a_new_user', working: true do
    #   context 'does nothing and returns false if' do
    #     it 'user doesnt exist' do
    #       game = FactoryBot.create(:game, :pregame)
    #       user_ids = game.users.ids
    #       invalid_id = (User.ids.last + 1)

    #       expect(game.rendezvous_a_new_user invalid_id).to eq false
    #       game.reload
    #       expect(game.users.ids).to eq user_ids
    #     end

    #     it 'user is already associated with game' do
    #       game = FactoryBot.create(:game, :pregame)
    #       user_ids = game.users.ids
    #       repeated_id = user_ids.first

    #       expect(game.rendezvous_a_new_user repeated_id).to eq false
    #       game.reload
    #       expect(game.users.ids).to eq user_ids
    #     end

    #     it 'player playing another game' do
    #       user_associated_game = FactoryBot.create(:game, :midgame)
    #       new_game = FactoryBot.create(:game, :pregame)
    #       user = user_associated_game.users.last

    #       user_associated_game_user_ids = user_associated_game.users.ids
    #       new_game_user_ids = new_game.users.ids

    #       expect(new_game.rendezvous_a_new_user user.id).to eq false
    #       new_game.reload
    #       expect(new_game.users.ids).to eq new_game_user_ids
    #       expect(user_associated_game.users.ids).to eq user_associated_game_user_ids
    #     end

    #     it 'the game is not in pregame mode' do
    #       new_game = FactoryBot.create(:game, :midgame)
    #       user = FactoryBot.create(:user)

    #       new_game_user_ids = new_game.users.ids

    #       expect(new_game.rendezvous_a_new_user user.id).to eq false
    #       new_game.reload
    #       expect(new_game.users.ids).to eq new_game_user_ids
    #     end
    #   end

    #   context 'creates a GamesUser association from game to the new player' do
    #     it 'when a user is rendezvouing with a new game and isnt currently playing one' do
    #       game = FactoryBot.create(:game, :pregame)
    #       user = FactoryBot.create(:user)
    #       game_user_ids = game.users.ids

    #       expect(game.rendezvous_a_new_user user.id).to eq true
    #       game.reload
    #       expect(game.users.ids).to eq game_user_ids + [user.id]
    #     end
    #   end
    # end

    # context '#commit_a_rendezvoused_user', working: true do
    #   context 'does nothing and returns false if' do
    #     it 'user is not associated with the game already' do
    #       game = FactoryBot.create(:game, :pregame)
    #       user =  FactoryBot.create(:user)
    #       users_game_name = 'NameName'

    #       expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq false

    #       game.reload
    #       expect(user.users_game_name).to eq nil
    #     end

    #     it "the game's status != pregame" do
    #       game = FactoryBot.create(:game, :pregame)
    #       user =  FactoryBot.create(:user)
    #       users_game_name = 'NameName'

    #       game.rendezvous_a_new_user user.id

    #       game.update(status: 'midgame', join_code: nil)
    #       expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq false

    #       game.reload
    #       expect(user.users_game_name).to eq nil
    #     end
    #   end

    #   context "assigns the user's game name to games_users.users_game_name if" do
    #     it 'associated user id and name string is received' do
    #       game = FactoryBot.create(:game, :pregame)
    #       user =  FactoryBot.create(:user)
    #       users_game_name = 'NameName'

    #       game.rendezvous_a_new_user user.id

    #       expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq true

    #       game.reload
    #       expect(user.users_game_name).to eq users_game_name
    #     end
    #   end
    # end

    # context '#next_player_after', working: true do
    #   it 'returns Empty relation if user not in game' do
    #     game = FactoryBot.create(:game, :midgame_without_cards)
    #     invalid_id = game.users.last.id + 1

    #     expect(game.send(:next_player_after, invalid_id)).to eq User.none
    #   end

    #   it 'returns the next user' do
    #     game = FactoryBot.create(:game, :midgame_without_cards)
    #     users = game.users.order(:id)

    #     expect(game.send(:next_player_after, users.first.id)).to eq users.second
    #     expect(game.send(:next_player_after, users.second.id)).to eq users.third
    #     expect(game.send(:next_player_after, users.third.id)).to eq users.first
    #   end
    # end

    # context '#create_placeholder_card', working: true do
    #   it "creates a drawing card if params passed a user_id and type = 'drawing'" do
    #     game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)
    #     user_id = game.users.first.id

    #     card = game.send(:create_placeholder_card, user_id, 'drawing')

    #     expect(card.drawing.blank?).to eq true
    #     expect(card.description_text).to eq nil
    #     expect(card.medium).to eq 'drawing'
    #     expect(card.uploader_id).to eq user_id
    #   end

    #   it "creates a drawing card if params passed a user_id and type = 'description'" do
    #     game = FactoryBot.create(:game, :midgame_without_cards)
    #     user_id = game.users.first.id

    #     card = game.send(:create_placeholder_card, user_id, 'description')

    #     expect(card.drawing.blank?).to eq true
    #     expect(card.description_text).to eq nil
    #     expect(card.description?).to eq true
    #     expect(card.uploader_id).to eq user_id
    #   end
    # end


    # context '#set_up_next_players_turn' do

    #   context 'can set up a normal next drawing' do

    #     it 'with NO placeholder waiting for current user' do
    #       game = FactoryBot.create(:game, :midgame_without_cards)
    #       gu = game.games_users.order(:id).first
    #       users = game.users.order(:id)
    #       card = FactoryBot.create(:description, uploader: users.first, idea_catalyst: gu, starting_games_user: gu) # description placeholder card
    #       gu.starting_card = card

    #       broadcast_params = game.set_up_next_players_turn gu.starting_card

    #       gu.reload
    #       game.reload
    #       expect(broadcast_params).to eq([ { game_over: false, set_complete: false, attention_users: users.second.id, prev_card: {id: card.id, description_text: card.description_text }} ])
    #       expect(gu.set_complete).to eq false

    #       expect( game.get_placeholder_card card.child_card.uploader_id ).to eq card.child_card # see if there is a valid placeholder for the next person
    #       expect(game.status).to eq 'midgame'
    #     end

    #     it 'with >= 1 placeholders waiting for current user' do
    #       game = FactoryBot.create(:game, :midgame_without_cards)
    #       users = game.users.order(:id)
    #       games_users = game.games_users.order(:id)

    #       # create a placeholder waiting for the current user
    #         prev_gu = games_users.first
    #         prev_card_of_waiting_placeholder = FactoryBot.create(:description, uploader: users.first, idea_catalyst: prev_gu, starting_games_user: prev_gu) # description placeholder card
    #         prev_gu.starting_card = prev_card_of_waiting_placeholder
    #         placeholder_waiting_for_current_user = FactoryBot.create(:drawing, uploader: users.second, drawing: nil, starting_games_user: prev_gu) # drawing placeholder card
    #         prev_gu.starting_card.child_card = placeholder_waiting_for_current_user

    #       current_gu = games_users.second
    #       current_gu.starting_card = FactoryBot.create(:description, uploader: users.second, idea_catalyst: current_gu, starting_games_user: current_gu) # description placeholder card

    #       expect do
    #         @broadcast_params = game.set_up_next_players_turn current_gu.starting_card
    #       end.to change{Card.count}.by(1)

    #       game.reload
    #       current_gu.reload
    #       prev_gu.reload
    #       expect(@broadcast_params).to eq([
    #                                        { game_over: false, set_complete: false, attention_users: users.third.id, prev_card: {id: current_gu.starting_card.id, description_text: current_gu.starting_card.description_text }}, #  message for next player with broadcast params containing placeholder
    #                                        { game_over: false, set_complete: false, attention_users: users.second.id, prev_card: {id: prev_card_of_waiting_placeholder.id, description_text: prev_card_of_waiting_placeholder.description_text }} # message to self for new card
    #                                      ])
    #       expect(games_users.map(&:set_complete).any?).to eq false

    #       expect( game.get_placeholder_card users.third.id ).to eq current_gu.starting_card.child_card # make sure there is a valid placeholder for the next person
    #       expect(game.status).to eq 'midgame'
    #     end
    #   end

    #   context 'can set up a normal next description', working: true do
    #     it 'with NO placeholder waiting for current user' do
    #       game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)
    #       gu = game.games_users.order(:id).first
    #       users = game.users.order(:id)
    #       card = FactoryBot.create(:drawing, uploader: users.first, idea_catalyst: gu, starting_games_user: gu) # drawing placeholder card
    #       gu.starting_card = card

    #       broadcast_params = game.set_up_next_players_turn gu.starting_card

    #       gu.reload
    #       game.reload
    #       expect(broadcast_params).to eq([ { game_over: false, set_complete: false, attention_users: users.second.id, prev_card: {id: card.id, drawing_url: card.drawing.url }}])
    #       expect(gu.set_complete).to eq false

    #       expect( game.get_placeholder_card card.child_card.uploader_id ).to eq card.child_card # see if there is a valid placeholder for the next person
    #       expect(game.status).to eq 'midgame'
    #     end

    #     it 'with >= 1 placeholders waiting for current user' do
    #       game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)
    #       users = game.users.order(:id)
    #       games_users = game.games_users.order(:id)

    #       # create a placeholder waiting for the current user
    #         prev_gu = games_users.first
    #         prev_card_of_waiting_placeholder = FactoryBot.create(:drawing, uploader: users.first, idea_catalyst: prev_gu, starting_games_user: prev_gu) # description placeholder card
    #         prev_gu.starting_card = prev_card_of_waiting_placeholder
    #         placeholder_waiting_for_current_user = FactoryBot.create(:drawing, uploader: users.second, drawing: nil, starting_games_user: prev_gu) # drawing placeholder card
    #         prev_gu.starting_card.child_card = placeholder_waiting_for_current_user

    #       current_gu = games_users.second
    #       current_gu.starting_card = FactoryBot.create(:drawing, uploader: users.second, idea_catalyst: current_gu, starting_games_user: current_gu) # description placeholder card

    #       expect do
    #         @broadcast_params = game.set_up_next_players_turn current_gu.starting_card
    #       end.to change{Card.count}.by(1)

    #       game.reload
    #       current_gu.reload
    #       prev_gu.reload
    #       expect(@broadcast_params).to eq([
    #                                        { game_over: false, set_complete: false, attention_users: users.third.id, prev_card: {id: current_gu.starting_card.id, drawing_url: current_gu.starting_card.drawing.url }}, #  message for next player with broadcast params containing placeholder
    #                                        { game_over: false, set_complete: false, attention_users: users.second.id, prev_card: {id: prev_card_of_waiting_placeholder.id, drawing_url: prev_card_of_waiting_placeholder.drawing.url }} # message to self for new card
    #                                      ])
    #       expect(games_users.map(&:set_complete).any?).to eq false

    #       expect( game.get_placeholder_card users.third.id ).to eq current_gu.starting_card.child_card # make sure there is a valid placeholder for the next person
    #       expect(game.status).to eq 'midgame'
    #     end
    #   end

    #   it 'current card finished the set, but other sets are not finished. Not Game Over' do
    #     game = FactoryBot.create(:game, :midgame_without_cards)
    #     gu = game.games_users.order(:id).first
    #     users = game.users.order(:id)
    #     gu.starting_card = FactoryBot.create(:description, uploader: users.first, starting_games_user: gu, idea_catalyst: gu) # description placeholder card
    #     gu.starting_card.child_card = FactoryBot.create(:drawing, uploader: users.second, starting_games_user: gu) # description placeholder card
    #     gu.starting_card.child_card.child_card = FactoryBot.create(:description, uploader: users.third,  starting_games_user: gu) # description placeholder card
    #     last_card = gu.starting_card.child_card.child_card

    #     broadcast_params = game.set_up_next_players_turn last_card.id

    #     #tests
    #     gu.reload
    #     game.reload
    #     expect(broadcast_params).to eq([{ game_over: false, attention_users: users.third.id, set_complete: true }])
    #     expect(gu.set_complete).to eq true
    #     expect(game.status).to eq 'midgame'
    #   end

    #   it 'current card finished the last set and finished the game. Game Over' do
    #     game = FactoryBot.create(:postgame, status: 'midgame')
    #     gu = game.games_users.order(:id).first
    #     gu.update(set_complete: false)
    #     users = game.users.order(:id)
    #     last_card = gu.starting_card.child_card.child_card

    #     broadcast_params = game.set_up_next_players_turn last_card.id

    #     gu.reload
    #     game.reload
    #     expect(broadcast_params).to eq([{ game_over: true }])
    #     expect(gu.set_complete).to eq true
    #     expect(game.status).to eq 'postgame'
    #   end
    # end

    # context '#upload_info_into_existing_card' do
    #   context 'does nothing and returns false if', todo: true do
    #     it 'user does not exist'
    #     it 'placeholder_card '
    #   end

    #   context 'succeeds if', working: true do
    #     xit 'updating drawing' do
    #       # get rid of the dropbox shit

    #       # expect_any_instance_of(Card).to receive(:parse_and_save_uri_for_drawing).once.and_call_original

    #       game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)
    #       gu = game.games_users.order(:id).first
    #       current_user = gu.user
    #       card_to_update = game.create_initial_placeholder_for_user current_user.id
    #       fake_file_data = "data:image/png;base64,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"
    #       fake_file_name = 'file_name'

    #       card_returned = game.upload_info_into_existing_card( current_user.id, { 'filename' => fake_file_name,  'data' => fake_file_data })

    #       expect(card_returned.uploader_id).to eq current_user.id
    #       expect(card_returned.starting_games_user_id).to eq gu.id
    #       expect(card_returned.description_text).to eq nil
    #       expect(card_returned.medium).to eq 'drawing'
    #       expect(card_returned.drawing_file_name).to eq fake_file_name
    #       expect(card_returned.drawing_file_size).not_to eq nil
    #     end

    #     it 'updating description' do
    #       game = FactoryBot.create(:game, :midgame_without_cards)

    #       gu = game.games_users.order(:id).first
    #       current_user = gu.user
    #       card_to_update = game.create_initial_placeholder_for_user current_user.id
    #       sample_description_text = "Suicidal Penguin"

    #       card_returned = game.upload_info_into_existing_card( current_user.id, { 'description_text' => sample_description_text } )

    #       expect(card_returned.uploader_id).to eq current_user.id
    #       expect(card_returned.starting_games_user_id).to eq gu.id
    #       expect(card_returned.description_text).to eq sample_description_text
    #       expect(card_returned.medium).to eq 'description'
    #       expect(card_returned.drawing_file_name).to eq nil
    #       expect(card_returned.drawing_file_size).to eq nil
    #     end
    #   end
    # end

    # context '#create_initial_placeholder_for_user', working: true do
    #   context 'starts game for a user by creating their initial' do
    #     it 'description placeholder card' do
    #       game = FactoryBot.create(:game, :midgame_without_cards)
    #       user = game.users.last
    #       card = game.create_initial_placeholder_for_user user.id
    #       gu = card.starting_games_user

    #       expect(card.medium).to eq 'description'
    #       expect(card.description_text).to eq nil
    #       expect(card.drawing_file_name).to eq nil
    #       expect(card.uploader_id).to eq user.id
    #       expect(card.idea_catalyst_id).to eq gu.id
    #       expect(card.starting_games_user.id).to eq gu.id
    #       expect(card.parent_card).to eq nil

    #       expect(gu.set_complete).to eq false
    #       expect(gu.user_id).to eq user.id
    #       expect(gu.game_id).to eq game.id
    #       expect(gu.starting_card.id).to eq card.id
    #     end

    #     it 'drawing placeholder card' do
    #       game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)
    #       user = game.users.last
    #       card = game.create_initial_placeholder_for_user user.id
    #       gu = card.starting_games_user

    #       expect(card.medium).to eq 'drawing'
    #       expect(card.description_text).to eq nil
    #       expect(card.drawing_file_name).to eq nil
    #       expect(card.uploader_id).to eq user.id
    #       expect(card.idea_catalyst_id).to eq gu.id
    #       expect(card.starting_games_user.id).to eq gu.id
    #       expect(card.parent_card).to eq nil


    #       expect(gu.set_complete).to eq false
    #       expect(gu.user_id).to eq user.id
    #       expect(gu.game_id).to eq game.id
    #       expect(gu.starting_card.id).to eq card.id
    #     end
    #   end
    # end

    # context '#create_subsequent_placeholder_for_next_player', working: true do
    #   context 'creates a placeholder card for the next player to be able to go' do
    #     it 'description placeholder card' do
    #       game = FactoryBot.create(:game, :midgame_without_cards, description_first: false)

    #       user = game.users.order(:id).first
    #       gu = user.gamesuser_in_current_game

    #       gu.starting_card = FactoryBot.create(:drawing, uploader_id: user.id, starting_games_user: gu)
    #       prev_card = gu.starting_card

    #       card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

    #       expect(card.medium).to eq 'description'
    #       expect(card.description_text).to eq nil
    #       expect(card.drawing_file_name).to eq nil
    #       expect(card.uploader_id).to eq user.id
    #       expect(card.idea_catalyst_id).to eq nil
    #       expect(card.starting_games_user.id).to eq gu.id
    #       expect(card.parent_card.id).to eq prev_card.id


    #       expect(gu.set_complete).to eq false
    #       expect(gu.user_id).to eq user.id
    #       expect(gu.game_id).to eq game.id
    #       expect(gu.starting_card.child_card.id).to eq card.id
    #     end

    #     it 'drawing placeholder card' do
    #       game = FactoryBot.create(:game, :midgame_without_cards)

    #       user = game.users.order(:id).first
    #       gu = user.gamesuser_in_current_game
    #       gu.starting_card = FactoryBot.create(:description, uploader_id: user.id, starting_games_user: gu)
    #       prev_card = gu.starting_card

    #       card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

    #       expect(card.medium).to eq 'drawing'
    #       expect(card.description_text).to eq nil
    #       expect(card.drawing_file_name).to eq nil
    #       expect(card.uploader_id).to eq user.id
    #       expect(card.idea_catalyst_id).to eq nil
    #       expect(card.starting_games_user.id).to eq gu.id
    #       expect(card.parent_card.id).to eq prev_card.id


    #       expect(gu.set_complete).to eq false
    #       expect(gu.user_id).to eq user.id
    #       expect(gu.game_id).to eq game.id
    #       expect(gu.starting_card.child_card.id).to eq card.id
    #     end
    #   end
    # end

    # context '#send_out_broadcasts_to_players_after_card_upload', working: true do
    #   it 'broadcasts params to game channel ' do
    #     game = FactoryBot.create(:game, :midgame_without_cards)
    #     sample_broadcast = [ { game_over: true }  ]
    #     allow(ActionCable).to receive_message_chain('server.broadcast').with("game_#{game.id}", sample_broadcast[0])

    #     game.send_out_broadcasts_to_players_after_card_upload sample_broadcast
    #   end
    # end

    # context '#get_placeholder_card', working: true do
    #   it 'find a placeholder card' do
    #     game = FactoryBot.create(:game, :midgame_without_cards)

    #     gu = game.games_users.order(:id).first
    #     gu2 = game.games_users.order(:id).second
    #     current_user = gu.user
    #     find_card = game.create_initial_placeholder_for_user current_user.id
    #     should_not_find_card = game.create_initial_placeholder_for_user gu2.user_id

    #     card = game.get_placeholder_card current_user.id

    #     find_card.reload

    #     expect(find_card.id).to eq card.id
    #   end
    # end
  end
end
