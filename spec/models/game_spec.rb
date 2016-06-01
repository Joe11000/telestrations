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

  context '#create_placeholder_card', working: true do
    it "creates a drawing card if params passed a user_id and drawing_or_description = 'drawing'" do
      game = FactoryGirl.create(:midgame_without_cards, description_first: false)
      user_id = game.users.first.id

      card = game.send(:create_placeholder_card, user_id, 'drawing')

      expect(card.drawing.blank?).to eq true
      expect(card.description_text).to eq nil
      expect(card.drawing_or_description).to eq 'drawing'
      expect(card.uploader_id).to eq user_id
    end

    it "creates a drawing card if params passed a user_id and drawing_or_description = 'description'" do
      game = FactoryGirl.create(:midgame_without_cards)
      user_id = game.users.first.id

      card = game.send(:create_placeholder_card, user_id, 'description')

      expect(card.drawing.blank?).to eq true
      expect(card.description_text).to eq nil
      expect(card.drawing_or_description).to eq 'description'
      expect(card.uploader_id).to eq user_id
    end
  end



  context '#upload_info_into_existing_card', working: true do
    context 'does nothing and returns false if' do
      it 'user does not exist'
      it 'placeholder_card '
    end

    context 'succeeds if' do
      it 'updating drawing' do
        # allow(Paperclip).to receive_message_chain('io_adapters.for') { Faker::Avatar.image }
        expect_any_instance_of(Card).to receive(:parse_and_save_uri_for_drawing).once.and_call_original

        game = FactoryGirl.create(:midgame_without_cards, description_first: false)
        gu = game.games_users.order(:id).first
        current_user = gu.user
        card_to_update = game.create_initial_placeholder_for_user current_user.id
        fake_file_data = "data:image/png;base64,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"
        fake_file_name = 'file_name'

        game.upload_info_into_existing_card( current_user.id, { filename: fake_file_name,  data: fake_file_data })

        card_to_update.reload

        expect(card_to_update.uploader_id).to eq current_user.id
        expect(card_to_update.starting_games_user_id).to eq gu.id
        expect(card_to_update.description_text).to eq nil
        expect(card_to_update.drawing_or_description).to eq 'drawing'
        expect(card_to_update.drawing_file_name).to eq fake_file_name
        expect(card_to_update.drawing_file_size).not_to eq nil
      end

      it 'updating description' do
        game = FactoryGirl.create(:midgame_without_cards)

        gu = game.games_users.order(:id).first
        current_user = gu.user
        card_to_update = game.create_initial_placeholder_for_user current_user.id
        sample_description_text = "Suicidal Penguin"

        game.upload_info_into_existing_card( current_user.id, { description_text: sample_description_text } )

        card_to_update.reload

        expect(card_to_update.uploader_id).to eq current_user.id
        expect(card_to_update.starting_games_user_id).to eq gu.id
        expect(card_to_update.description_text).to eq sample_description_text
        expect(card_to_update.drawing_or_description).to eq 'description'
        expect(card_to_update.drawing_file_name).to eq nil
        expect(card_to_update.drawing_file_size).to eq nil
      end
    end
  end

  context '#create_initial_placeholder_for_user', working: true do
    context 'starts game for a user by creating their initial' do
      it 'description placeholder card' do
        game = FactoryGirl.create(:midgame_without_cards)
        user = game.users.last
        card = game.create_initial_placeholder_for_user user.id
        gu = card.starting_games_user

        expect(card.drawing_or_description).to eq 'description'
        expect(card.description_text).to eq nil
        expect(card.drawing_file_name).to eq nil
        expect(card.uploader_id).to eq user.id
        expect(card.idea_catalyst_id).to eq gu.id
        expect(card.starting_games_user.id).to eq gu.id
        expect(card.parent_card).to eq nil

        expect(gu.set_complete).to eq false
        expect(gu.user_id).to eq user.id
        expect(gu.game_id).to eq game.id
        expect(gu.starting_card.id).to eq card.id
      end

      it 'drawing placeholder card' do
        game = FactoryGirl.create(:midgame_without_cards, description_first: false)
        user = game.users.last
        card = game.create_initial_placeholder_for_user user.id
        gu = card.starting_games_user

        expect(card.drawing_or_description).to eq 'drawing'
        expect(card.description_text).to eq nil
        expect(card.drawing_file_name).to eq nil
        expect(card.uploader_id).to eq user.id
        expect(card.idea_catalyst_id).to eq gu.id
        expect(card.starting_games_user.id).to eq gu.id
        expect(card.parent_card).to eq nil


        expect(gu.set_complete).to eq false
        expect(gu.user_id).to eq user.id
        expect(gu.game_id).to eq game.id
        expect(gu.starting_card.id).to eq card.id
      end
    end
  end

  context '#create_subsequent_placeholder_for_next_player', working: true do
    context 'starts game for a user by creating their initial' do
      it 'description placeholder card' do
        game = FactoryGirl.create(:midgame_without_cards, description_first: false)

        user = game.users.order(:id).first
        gu = user.gamesuser_in_current_game
        gu.starting_card = FactoryGirl.create(:description, uploader_id: user.id, starting_games_user: gu)
        prev_card = gu.starting_card

        card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

        expect(card.drawing_or_description).to eq 'drawing'
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
        game = FactoryGirl.create(:midgame_without_cards, description_first: false)

        user = game.users.order(:id).first
        gu = user.gamesuser_in_current_game
        gu.starting_card = FactoryGirl.create(:description, uploader_id: user.id, starting_games_user: gu)
        prev_card = gu.starting_card

        card = game.create_subsequent_placeholder_for_next_player user.id, prev_card.id

        expect(card.drawing_or_description).to eq 'drawing'
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

  context '#get_placeholder_card', working: true do
    it 'find a placeholder' do
      game = FactoryGirl.create(:midgame_without_cards)

      gu = game.games_users.order(:id).first
      gu2 = game.games_users.order(:id).second
      current_user = gu.user
      find_card = game.create_initial_placeholder_for_user current_user.id
      should_not_find_card = game.create_initial_placeholder_for_user gu2.user_id

      card = game.get_placeholder_card current_user.id

      find_card.reload

      expect(find_card.id).to eq card.id
    end
  end
    # context '#send_out_broadcasts_to_players_after_card_upload'
end
