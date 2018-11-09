require 'rails_helper'
require 'support/login'

RSpec.describe "InGameCardUploads", type: :request do
  include LoginHelper::RequestTests

  shared_examples_for "redirect if user shouldn't be playing this game" do
    context 'user NOT logged in' do
      context "user doesn't exist" do
        it 'redirects them back to home page' do
          set_signed_cookies({user_id: nil})

          expect( get new_game_path ).to redirect_to(login_path)
        end
      end
    end

    context "user exists and" do
      context 'user has no associated game' do
        it 'then is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:user).id})

          expect( get new_game_path ).to redirect_to(choose_game_type_page_path)
        end
      end

      context 'user should be waiting for their game to start' do
        it 'then user is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:pregame, callback_wanted: :pregame).users.first.id})

          expect( get new_game_path ).to redirect_to(choose_game_type_page_path)
        end
      end

      context 'user just finished their game' do
        it 'then user is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:postgame, callback_wanted: :postgame).users.first.id})

          expect( get new_game_path ).to redirect_to(choose_game_type_page_path)
        end
      end
    end
  end

  context 'POST cards/in_game_card_uploads first card'  do
    it_behaves_like "redirect if user shouldn't be playing this game"

    context 'user uploads first card' do
      context 'description card', :r5 do
        before do
          @game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
          @gu_1 = @game.games_users.first
          @current_user = @gu_1.user
          @card_being_updated = @gu_1.starting_card
          @description_text = 'user uploads first card description text'

          set_signed_cookies({user_id: @current_user.id})

          post in_game_card_uploads_path, params: { card: { description_text: @description_text } ,  format: :js}

          @gu_1.reload
          @current_user.reload
          @card_being_updated.reload
        end

        it 'which updates the placeholder card that was created at the start of the game' do
          expect(@card_being_updated.description_text).to eq @description_text
          expect(@card_being_updated.description?).to eq true

          expect(@card_being_updated.drawing.attached?).to eq false
          expect(@card_being_updated.placeholder).to eq false
          expect(@card_being_updated.idea_catalyst_id).to eq @gu_1.id
          expect(@card_being_updated.starting_games_user_id).to eq @gu_1.id
          expect(@card_being_updated.uploader_id).to eq @current_user.id
          expect(@card_being_updated.parent_card_id).to eq nil
          expect(@card_being_updated.out_of_game_card_upload).to eq false
        end

        it 'has set up the placeholder for the next player in the passing order' do
          card_being_updated_child_card = @card_being_updated.child_card

          expect(card_being_updated_child_card).to be_a Card
          expect(card_being_updated_child_card.drawing?).to eq true
          expect(card_being_updated_child_card.placeholder).to eq true
          expect(card_being_updated_child_card.drawing.attached?).to eq false

          game_passing_order = JSON.parse(@game.passing_order)
          current_user_index = game_passing_order.index(@current_user.id)
          next_player_index = (current_user_index + 1) % @game.users.count
          expect(@card_being_updated.child_card.uploader_id).to eq game_passing_order[next_player_index]
        end

        it 'returned correct status code' do
          expect(response).to have_http_status :ok
        end

        it 'doesnt have a completed games_user set' do
          expect(@gu_1.set_complete).to eq false
        end


        context 'Move 1 statuses for people involved', :r5_wip do
          it '' do
            game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
            gu_1, gu_2, gu_3 = @game.games_users.order(id: :asc)
            user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

            set_signed_cookies({user_id: @current_user.id})

            expected_response = {
                                  'statuses': [
                                                {
                                                  'attention_users': [user_1.id],
                                                  'user_status': 'waiting'
                                                },
                                               {
                                                  'attention_users': [user_2.id],
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }



            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", expected_response.to_json )

            post in_game_card_uploads_path, params: { card: { description_text: @description_text } ,  format: :js}

            expect(response).to have_http_status :ok
          end
        end



        # it 'broadcasts the correct message to other users', :r5_wip do
        #   current_user_index = 0
        #   next_user_index = 1

        #   game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
        #   gus = game.games_users
        #   current_user = gus[current_user_index].user
        #   next_user    = gus[next_user_index].user
        #   description_text = 'user uploads first card description text'
        #   expected_status_response = game.get_status_for_users([current_user, next_user]).to_json

        #   expect(ActionCable.server).to receive(:broadcast).with( "game_#{game.id}", expected_status_response )

        #   set_signed_cookies({user_id: current_user.id})
        #   post in_game_card_uploads_path, params: { card: { description_text: description_text }, format: :js}
        # end
      end

      context 'drawing card'
    end

    context 'user uploads a non final card' do
      context 'drawing card' do
        before do
          @game = FactoryBot.create :midgame, callback_wanted: :midgame, round: 1, move: 3
          @gu_1, @gu_2 = @game.games_users
          @current_user = @gu_1.user
          @current_users_current_deck = @gu_3
          @card_being_updated = @current_users_current_deck.starting_card.child_card

          set_signed_cookies({user_id: @current_user.id})

          @file_name = 'Ace_of_Diamonds.jpg'
          @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")

          post in_game_card_uploads_path, params: {
                                                    card: {
                                                            drawing: @drawn_image
                                                          },
                                                    format: :js
                                                  }
          @gu_3.reload
          @current_user.reload
          @card_being_updated.reload
        end

        it 'which updates the placeholder card', :r5 do
          @card_being_updated.reload
          expect(@card_being_updated.drawing?).to eq true
          expect(@card_being_updated.description_text).to eq nil
          expect(@card_being_updated.idea_catalyst_id).to eq nil
          expect(@card_being_updated.starting_games_user_id).to eq @current_users_current_deck.user_id
          expect(@card_being_updated.uploader_id).to eq @current_user.id
          byebug
          expect(@card_being_updated.placeholder).to eq false
          expect(@card_being_updated.out_of_game_card_upload).to eq false
          expect(@card_being_updated.drawing.attached?).to eq true
        end

        it 'has set up the placeholder for the next player in the passing order' do
          card_being_updateds_child_card = @card_being_updated.child_card
          expect(card_being_updateds_child_card).to be_a Card
          expect(card_being_updateds_child_card.drawing.attached?).to eq false

          game_passing_order = JSON.parse(@game.passing_order)
          current_user_index = game_passing_order.index(@current_user.id)
          next_player_index = (current_user_index + 1) % @game.users.count
          expect(card_being_updateds_child_card.uploader_id).to eq game_passing_order[next_player_index]
          expect(card_being_updateds_child_card.description?).to eq true
        end

        it 'parent is of the correct type and is completed card of opposite type' do
          card_being_updated_parent_card = @card_being_updated.parent_card
          byebug
          expect(card_being_updated_parent_card.id).to eq @gu_2.starting_card.id
          expect(card_being_updated_parent_card.drawing.attached?).to eq false
          expect(card_being_updated_parent_card.description?).to eq true
          expect(card_being_updated_parent_card.description_text).to be_a String
          expect(card_being_updated_parent_card.placeholder).to be_a false
        end

        it 'doesnt have a completed games_user set' do
          expect(@gu_2.set_complete).to eq false
        end

        it 'returned correct status code' do
          expect(response).to have_http_status :ok
        end

        it 'broadcasts the correct message to other users' do

        end
      end

      context 'description card'
    end

    context 'user uploads a final card' do
      context 'drawing'

      context 'description card' do
        before :all do
          @game = FactoryBot.create :midgame, callback_wanted: :midgame
          @gu_3 = @game.games_users[2]
          @current_user = @gu_3.user
          @card_being_updated = @gu_3.starting_card.child_card.child_card
          @description_text = 'user uploads final card description text'

          set_signed_cookies({user_id: @current_user.id})

          post in_game_card_uploads_path, params: { card: { description_text: @description_text },  format: :js}
          @gu_3.reload
          @current_user.reload
          @card_being_updated.reload
        end

        it 'which updates the placeholder card' do
          byebug
          expect(@card_being_updated.description_text).to eq @description_text
          expect(@card_being_updated.drawing.attached?).to eq false

          expect(@card_being_updated.description?).to eq true
          expect(@card_being_updated.idea_catalyst_id).to eq nil
          expect(@card_being_updated.starting_games_user_id).to eq @gu_3.id
          expect(@card_being_updated.uploader_id).to eq @current_user.id
          expect(@card_being_updated.out_of_game_card_upload).to eq false

        end

        it 'parent is of the correct type and is completed card of opposite type' do
          expect(@card_being_updated.parent_card.drawing.attached?).to eq true
          expect(@card_being_updated.parent_card.drawing?).to eq true
          expect(@card_being_updated.parent_card.description_text).to eq nil
        end

        xit 'has NOT set up the placeholder for the next player in the passing order' do
          # byebug
          expect(@card_being_updated.child_card).to eq nil
        end

        it 'returned correct status code' do
          expect(response).to have_http_status :ok
        end

        xit 'doesnt have a completed games_user set' do
          expect(@gu_3.set_complete).to eq true
        end

        it 'broadcasts the correct message to other users' do

        end
      end
    end
  end
end
