require 'spec_helper'
require 'rails_helper'

RSpec.describe Game, type: :model do

  xcontext 'model validations' do
    it { is_expected.to have_many(:games_users).inverse_of(:game).dependent(:destroy) }
  end

  context 'factory' do

    it ':game is valid' do
      expect(FactoryGirl.create(:game).valid?).to eq true
    end

    context ':midgame' do
      before :all do
        @midgame = FactoryGirl.create(:midgame)
      end

      it 'is valid' do
        expect(FactoryGirl.create(:midgame).valid?).to eq true
      end

      it 'has correct associations' do
        expect(@midgame.users.count).to eq 3


        @midgame.users.each do |user|
          byebug
          expect(user.starting_cards.length).to eq 1
          expect(user.starting_cards.first.child_card.parent_card).to eq user.starting_cards.first
        end
      end

      it 'status' do
        expect(@midgame.status).to eq 'midgame'
      end

      it 'removes join code' do
        expect(@midgame.join_code).to eq nil
      end
    end


    context ':postgame' do
      before :all do
        @postgame = FactoryGirl.create(:postgame)
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

    context 'public_pre_game' do
      before :all do
        @public_pre_game = FactoryGirl.create(:public_pre_game)
      end

      it 'has 3 users attached' do
        expect(@public_pre_game.users.count).to eq 3
      end

      it 'is a public game' do
        expect(@public_pre_game.is_private).to eq false
      end

      it 'allows additional players' do
        expect(@public_pre_game.join_code).to match /^[a-zA-Z]{4}$/
      end

      it 'game has not been completed' do
        expect(@public_pre_game.status).to eq 'pregame'
      end

      it 'game has not been deleted for some strange reason' do
        expect(@public_pre_game.deleted_at).to eq nil
      end
    end
  end

  context 'basic instantiation' do
    let(:game){FactoryGirl.create(:game)}

    before(:each) do
      Game.delete_all
    end

    it 'is_private is set to true' do
      expect(game.is_private).to eq true
    end

    it 'status is defaulted to pregame' do
      expect(game.status).to eq 'pregame'
    end

    it 'a 4 digit join_code' do
      10.times{ FactoryGirl.create(:game)}
      expect(Game.pluck(:join_code).length).to eq 10
    end
  end

  context 'scope' do
    it 'random_public_game' do
      Game.destroy_all
      g1 = FactoryGirl.create(:public_pre_game)
      FactoryGirl.create(:public_pre_game, is_private: true)
      FactoryGirl.create(:midgame)
      FactoryGirl.create(:midgame, is_private: true)

      expect(Game.random_public_game).to eq g1
      expect(Game.random_public_game).to eq g1 # intentionally duplicated test
    end
  end

  context 'methods' do
    context '#cards_from_finished_game' do
      before(:all) do
        @game = FactoryGirl.create(:postgame)
        @cards = @game.cards_from_finished_game
      end

      it 'returns correct ordering of cards' do
        first_user, second_user, third_user = @game.users

        first_starting_card, second_starting_card, third_starting_card = @game.starting_cards

        expect(@cards).to eq [
                                [
                                  [first_starting_card.uploader.games_users.first.users_game_name, first_starting_card ],
                                  [first_starting_card.child_card.uploader.users_game_name, first_starting_card.child_card ],
                                  [first_starting_card.child_card.child_card.uploader.users_game_name, first_starting_card.child_card.child_card ]
                                ],
                                [
                                  [second_starting_card.uploader.games_users.first.users_game_name, second_starting_card ],
                                  [second_starting_card.child_card.uploader.users_game_name, second_starting_card.child_card ],
                                  [second_starting_card.child_card.child_card.uploader.users_game_name, second_starting_card.child_card.child_card ]
                                ],
                                [
                                  [third_starting_card.uploader.games_users.first.users_game_name, third_starting_card ],
                                  [third_starting_card.child_card.uploader.users_game_name, third_starting_card.child_card ],
                                  [third_starting_card.child_card.child_card.uploader.users_game_name, third_starting_card.child_card.child_card ]
                                ]
                             ]

      end
    end

    context '#remove_player' do
      context 'does nothing and returns false if' do
        it 'user does not exist' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.remove_player invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user not associated with game' do
          game = FactoryGirl.create(:public_pre_game)
          random_user = FactoryGirl.create(:user)

          user_ids = game.users.ids
          random_user_id = random_user.id

          expect(game.remove_player random_user_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end
      end

      context 'if other users are rendezvouing' do
        it 'removes only the user' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          valid_id = user_ids.first

          expect(game.remove_player valid_id).to eq true
          game.reload
          expect(game.users.ids).to eq user_ids.last(2)
        end
      end

      context 'if NO other users are rendezvouing' do
        it 'removes the user and the game' do
          game = FactoryGirl.create(:public_pre_game)
          user = game.users.first
          game.users.where.not(id: user.id).destroy_all


          expect(game.remove_player user.id).to eq true
          expect(user.current_game).to eq Game.none
          expect(game.destroyed?).to eq true
        end
      end
    end

    context '#rendezvous_a_new_user' do
      context 'does nothing and returns false if' do
        it 'user doesnt exist' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.rendezvous_a_new_user invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user is already associated with game' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          repeated_id = user_ids.first

          expect(game.rendezvous_a_new_user repeated_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'player playing another game' do
          user_associated_game = FactoryGirl.create(:midgame)
          new_game = FactoryGirl.create(:public_pre_game)
          user = user_associated_game.users.last

          user_associated_game_user_ids = user_associated_game.users.ids
          new_game_user_ids = new_game.users.ids

          expect(new_game.rendezvous_a_new_user user.id).to eq false
          new_game.reload
          expect(new_game.users.ids).to eq new_game_user_ids
          expect(user_associated_game.users.ids).to eq user_associated_game_user_ids
        end

        it 'the game is not in pregame mode' do
          new_game = FactoryGirl.create(:midgame)
          user = FactoryGirl.create(:user)

          new_game_user_ids = new_game.users.ids

          expect(new_game.rendezvous_a_new_user user.id).to eq false
          new_game.reload
          expect(new_game.users.ids).to eq new_game_user_ids
        end
      end

      context 'creates a GamesUser association from game to the new player' do
        it 'when a user is rendezvouing with a new game and isnt currently playing one' do
          game = FactoryGirl.create(:public_pre_game)
          user = FactoryGirl.create(:user)
          game_user_ids = game.users.ids

          expect(game.rendezvous_a_new_user user.id).to eq true
          game.reload
          expect(game.users.ids).to eq game_user_ids + [user.id]
        end
      end
    end

    context '#commit_a_rendezvoused_user' do
      context 'does nothing and returns false if' do
        it 'user is not associated with the game already' do
          game = FactoryGirl.create(:public_pre_game)
          user =  FactoryGirl.create(:user)
          users_game_name = 'NameName'

          expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq false

          game.reload
          expect(user.users_game_name).to eq nil
        end

        it "the game's status != pregame" do
          game = FactoryGirl.create(:public_pre_game)
          user =  FactoryGirl.create(:user)
          users_game_name = 'NameName'

          game.rendezvous_a_new_user user.id

          game.update(status: 'midgame', join_code: nil)
          expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq false

          game.reload
          expect(user.users_game_name).to eq nil
        end
      end

      context "assigns the user's game name to games_users.users_game_name if" do
        it 'associated user id and name string is received' do
          game = FactoryGirl.create(:public_pre_game)
          user =  FactoryGirl.create(:user)
          users_game_name = 'NameName'

          game.rendezvous_a_new_user user.id

          expect(game.commit_a_rendezvoused_user user.id, users_game_name).to eq true

          game.reload
          expect(user.users_game_name).to eq users_game_name
        end
      end
    end

    context '#next_player_after' do
      it 'returns Empty relation if user not in game' do
        game = FactoryGirl.create(:midgame)
        invalid_id = game.users.last.id + 1

        expect(game.send(:next_player_after, invalid_id)).to eq User.none
      end

      it 'returns the next user' do
        game = FactoryGirl.create(:midgame)
        users = game.users

        expect(game.send(:next_player_after, users.first.id)).to eq users.second
        expect(game.send(:next_player_after, users.second.id)).to eq users.third
        expect(game.send(:next_player_after, users.third.id)).to eq users.first
      end
    end

    context '#upload_card' do
      context 'when uploading a drawing' do
        context 'fails to upload and does nothing if' do
          it 'incorrect parameters'
          it 'person does not exist'
        end

        context 'uploads card' do
          it 'sets the set_complete in games_users when all a set is complete are filled'

          it 'triggers a waiting screen until all users are done'
        end
      end
    end


    context '#get_placeholder_card', all: true do
      context 'fails, does nothing, and returns if' do
        before :all do
          @game = FactoryGirl.create(:midgame)
          @prev_card = @game.starting_cards.order(:id).first
          @prev_card.destroy
        end

        xit 'user does not exist' do
          invalid_user_id = 1234123412341

          expect(@game.get_placeholder_card invalid_user_id).to raise_error
        end
      end

      context 'succeeds if' do
        context 'a placeholder card exists' do
          context 'and returns' do
            context 'the drawing card that has' do
              it 'no parent_card' do
                game = FactoryGirl.create(:midgame, description_first: false)

                # replace placeholder card for this test
                gu = game.games_users.order(:id).first
                current_user = gu.starting_card.uploader
                gu.starting_card.destroy
                find_card = FactoryGirl.create(:drawing, uploader_id: current_user.id, drawing_file_name: nil)
                gu.starting_card = find_card

                expect do
                  @returned_card = game.get_placeholder_card current_user.id
                end.to change{Card.count}.by(0)

                expect(@returned_card.id).to eq find_card.id
              end

              it 'a parent card' do
                game = FactoryGirl.create(:midgame)

                # replace placeholder card for this test
                gu = game.games_users.order(:id).second
                current_user = gu.starting_card.child_card.uploader
                gu.starting_card.child_card.destroy
                find_card = FactoryGirl.create(:drawing, uploader_id: current_user.id, drawing_file_name: nil)
                gu.starting_card.child_card = find_card

                expect do
                  @returned_card = game.get_placeholder_card current_user.id
                end.to change{Card.count}.by(0)

                expect(@returned_card.id).to eq find_card.id
              end
            end

            context 'a description card that has' do
              it 'no parent card' do
                game = FactoryGirl.create(:midgame)

                # replace placeholder card for this test
                gu = game.games_users.order(:id).first
                current_user = gu.starting_card.uploader
                gu.starting_card.destroy
                find_card = FactoryGirl.create(:description, uploader_id: current_user.id, description_text: nil)
                gu.starting_card = find_card

                expect do
                  @returned_card = game.get_placeholder_card current_user.id
                end.to change{Card.count}.by(0)

                expect(@returned_card.id).to eq find_card.id
              end

              it 'a parent card' do
                game = FactoryGirl.create(:midgame)

                # replace placeholder card for this test
                gu = game.games_users.order(:id).second
                current_user = gu.starting_card.child_card.uploader
                gu.starting_card.child_card.destroy
                find_card = FactoryGirl.create(:description, uploader_id: current_user.id, description_text: nil)
                gu.starting_card.child_card = find_card

                expect do
                  @returned_card = game.get_placeholder_card current_user.id
                end.to change{Card.count}.by(0)

                expect(@returned_card.id).to eq find_card.id
              end
            end
          end
        end

        context 'no placeholder_card exists for user' do
          context "users last card DOES belong to to this game's completed set of cards" do
            it 'is returned an empty relation, meaning the user has no additional cards to draw/describe' do
              game = FactoryGirl.create(:postgame, status: 'midgame')
              current_user = game.users.order(:id).first

              expect(game.get_placeholder_card current_user.id).to eq Card.none
            end
          end

          context "users last card DOES NOT belong to to this game's completed set of cards" do
            context 'the method creates a new drawing card with' do
              it 'no prev_card', focus: true do
                game = FactoryGirl.create(:midgame)
                gu = game.games_users.order(:id).first
                current_user = gu.user
                gu.starting_card.destroy

                # expect(Card).to receive(:create_placeholder_card).once.and_call_original

                expect {
                  @returned_card = game.get_placeholder_card current_user.id
                }.to change{Card.count}.by(1)

                gu.reload
                expect(@returned_card.drawing_or_description).to eq 'drawing'
                expect(gu.starting_card.id).to eq @returned_card.id
                expect(@returned_card.description_text).to eq nil
                expect(@returned_card.drawing_file_name).to eq nil
              end

              it 'a prev_card' do
                game = FactoryGirl.create(:midgame)
                gu = game.games_users.order(:id).second
                prev_card = gu.starting_card
                current_user = prev_card.child_card.uploader
                prev_card.child_card.destroy

                expect(Card).to receive(:create_placeholder_card).once.and_call_original

                expect {
                  @returned_card = game.get_placeholder_card current_user.id, { drawing_or_description: 'drawing', prev_card: prev_card.id }
                }.to change{Card.count}.by(1)

                prev_card.reload
                expect(@returned_card.drawing_or_description).to eq 'drawing'
                expect(prev_card.child_card.id).to eq @returned_card.id
                expect(@returned_card.description_text).to eq nil
                expect(@returned_card.drawing_file_name).to eq nil
              end
            end

            context 'the method creates a new description card' do
              it 'no prev_card' do
                game = FactoryGirl.create(:midgame)
                gu = game.games_users.order(:id).first
                current_user = gu.user
                gu.starting_card.destroy

                expect(Card).to receive(:create_placeholder_card).once.and_call_original

                expect {
                  @returned_card = game.get_placeholder_card current_user.id, { drawing_or_description: 'description'}
                }.to change{Card.count}.by(1)

                gu.reload
                expect(@returned_card.drawing_or_description).to eq 'description'
                expect(gu.starting_card.id).to eq @returned_card.id
                expect(@returned_card.description_text).to eq nil
                expect(@returned_card.drawing_file_name).to eq nil
              end

              it 'a prev_card' do
                game = FactoryGirl.create(:midgame)
                users = game.users.order(:id)
                Card.destroy_all
                gu = game.games_users.order(:id).first
                gu.starting_card = Game.create_placeholder_card users.first, 'drawing'
                prev_card = gu.starting_card
                current_user = users.second

                expect(Card).to receive(:create_placeholder_card).once.and_call_original

                expect {
                  @returned_card = game.get_placeholder_card current_user.id, { drawing_or_description: 'description', prev_card: prev_card.id }
                }.to change{Card.count}.by(1)

                prev_card.reload
                expect(@returned_card.drawing_or_description).to eq 'description'
                expect(prev_card.child_card.id).to eq @returned_card.id
                expect(@returned_card.description_text).to eq nil
                expect(@returned_card.drawing_file_name).to eq nil
              end
            end
          end
        end

        end
      end
    end


    it 'self.get_placeholder_card' do
      game = FactoryGirl.create(:midgame)

      find_card = game.starting_cards.order(:id).first
      user = find_card.uploader

      # edit an existing completed description card for this test
        dont_find_card = game.starting_cards.order(:id).last.child_card.child_card
        dont_find_card.update(description_text: nil, drawing: nil)


      expect(game.get_placeholder_card user.id).to eq find_card.id
      expect(user.id).not_to eq dont_find_card.uploader_id
    end

   context 'self.create_placeholder_card' do
    it "creates a drawing card if params passed a user_id and drawing_or_description = 'drawing'" do
      user_id = 1

      card = Game.create_placeholder_card user_id, 'drawing'

      expect(card.drawing.blank?).to eq true
      expect(card.description_text.blank?).to eq true
      expect(card.drawing_or_description).to eq 'drawing'
      expect(card.uploader_id).to eq user_id
    end

    it "creates a drawing card if params passed a user_id and drawing_or_description = 'description'" do
      user_id = 1

      card = Game.create_placeholder_card user_id, 'description'

      expect(card.drawing.blank?).to eq true
      expect(card.description_text.blank?).to eq true
      expect(card.drawing_or_description).to eq 'description'
      expect(card.uploader_id).to eq user_id
    end
  end

  context '#fill_in_info_for_placeholder_card' do


    context '#upload_info_into_existing_card' do
      context 'does nothing and returns false if' do
        it 'user does not exist'
        it 'placeholder_card '
      end

      context 'succeeds if' do
        xit 'updating drawing' do
          game = FactoryGirl.create(:midgame)
          gu = game.games_users.order(:id).first
          card_to_update = gu.starting_card
          current_user = card_to_update.uploader

          allow_any_instance_of(Card).to receive(:parse_and_save_uri_for_drawing).once.and_call_original

          expect(Paperclip).to receive(:io_adapters).and_return() .for(paperclip_card_params[:data])
          card_to_update.reload
          expect(card_to_update)


        end
        it 'updating description'
      end

    end
#
    # context '#send_out_broadcasts_to_players_after_card_upload'
  end
end
