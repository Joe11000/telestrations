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


    # context '#get_status_for_user', :r5 do
    #   context 'returns successful message for a player midgame' do
    #     context 'returns correct user for message if' do
    #       context 'user has placeholder for a drawing card' do
    #         it 'user should be drawing a picture' do
    #             game = FactoryBot.create(:midgame, callback_wanted: :midgame)
    #             user_1, user_2, user_3 = game.users.order(id: :asc)
    #             current_user = user_2

    #             expected_response = {
    #                                   attention_users: [user_2.id],
    #                                   current_user_id: user_2.id,
    #                                   game_over: false,
    #                                   previous_card: {
    #                                                     medium: 'description',
    #                                                     description_text: game.get_placeholder_card(user_2.id).parent_card.description_text
    #                                                   },
    #                                   user_status: 'working_on_card'
    #                                 }

    #             expect( game.get_status_for_user(current_user) ).to eq expected_response
    #         end

    #         context 'user should be writing a description' do
    #           it 'no previous card' do
    #             game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
    #             current_user = game.users.first

    #             expected_response = {
    #                                   attention_users: [current_user.id],
    #                                   current_user_id: current_user.id,
    #                                   game_over: false,
    #                                   user_status: 'working_on_card'
    #                                 }

    #             expect( game.get_status_for_user(current_user) ).to eq expected_response
    #           end

    #           it 'yes, previous card', :r5 do
    #             game = FactoryBot.create(:midgame, callback_wanted: :midgame)
    #             user_1, user_2, user_3 = game.users.order(id: :asc)
    #             gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
    #             current_user = user_2

    #             # user 2 has a drawing card at the moment, and needs to be on their next card for this test
    #               gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
    #                                                          content_type: 'image/jpg', \
    #                                                          filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
    #               gu_1.starting_card.child_card.update(placeholder: false);



    #             current_user_placeholder_description = game.get_placeholder_card(current_user.id)
    #             previous_card = gu_3.starting_card.child_card

    #             drawing_url = rails_blob_path( previous_card.drawing, disposition: 'attachment')

    #             expected_response = {
    #                                   attention_users: [current_user.id],
    #                                   current_user_id: current_user.id,
    #                                   game_over: false,
    #                                   user_status: 'working_on_card',
    #                                   previous_card: {
    #                                      medium: 'drawing',
    #                                      drawing_url: drawing_url
    #                                    }
    #                                 }


    #             expect( game.get_status_for_user(current_user) ).to eq expected_response
    #           end
    #         end

    #         it 'after uploading a card a user has to wait for card to be passed to them' do
    #           game = FactoryBot.create(:midgame, callback_wanted: :midgame)
    #           user_1, user_2, user_3 = game.users.order(id: :asc)
    #           current_user = user_1

    #           expected_response = { attention_users: [current_user.id],
    #                                 current_user_id: current_user.id,
    #                                 game_over: false,
    #                                 user_status: 'waiting' }

    #           expect( game.get_status_for_user(current_user) ).to eq expected_response
    #         end

    #         it 'user_1 is finished, but user 3 has not' do
    #           # user 1 has the finished message while they wait for user 3 to finish
    #           game = FactoryBot.create(:postgame, callback_wanted: :postgame)
    #           gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

    #            # undo the 3rd user's final card
    #             game.midgame!
    #             gu_1.update(set_complete: false)
    #             final_card = gu_1.starting_card.child_card.child_card
    #             final_card.update(placeholder: true)

    #           user_1, user_2, user_3 = game.users.order(id: :asc)
    #           current_user = user_1

    #           # user 1 should see a message that he is done
    #           expected_response = { attention_users: [current_user.id],
    #                                 current_user_id: current_user.id,
    #                                 game_over: false,
    #                                 user_status: 'finished' }
    #             byebug
    #           expect( game.get_status_for_user(current_user) ).to eq expected_response
    #         end


    #         it 'game_over when all players are finished' do
    #           game = FactoryBot.create(:postgame, callback_wanted: :postgame)
    #           gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

    #           game.midgame!

    #           user_1_id, user_2_id, user_3_id = gu_1.user_id, gu_2.user_id, gu_3.user_id
    #           current_user = gu_1.user

    #           expected_response = { attention_users: [user_1_id, user_2_id, user_3_id],
    #                                 current_user_id: user_1_id,
    #                                 game_over: true,
    #                                 url_redirect: game_path(game.id) } # last player finishes

    #           expect( game.get_status_for_user(current_user) ).to eq expected_response
    #         end
    #       end
    #     end
    #   end
    #   context 'returns unsuccessfully for a player not in midgame' do
    #     it 'game is a pregame' do
    #       game = FactoryBot.create(:pregame, callback_wanted: :pregame)
    #       current_user = game.users.first

    #       expect( game.get_status_for_user(current_user) ).to eq false
    #     end

    #     it 'game is a postgame' do
    #       game = FactoryBot.create(:postgame, callback_wanted: :postgame)
    #       current_user = game.users.first

    #       expect( game.get_status_for_user(current_user) ).to eq false
    #     end
    #   end
    # end

  context 'POST cards/in_game_card_uploads first card'  do
    it_behaves_like "redirect if user shouldn't be playing this game"

    context 'user uploads first card' do
      context 'description card' do
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

          expect(@card_being_updated_child_card).to be_a Card
          expect(@card_being_updated_child_card.drawing?).to eq true
          expect(@card_being_updated_child_card.placeholder).to eq false
          expect(@card_being_updated_child_card.drawing.attached?).to eq false

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

        it 'broadcasts the correct message to other users' do
          expect(ActionCable.server).to receive(:broadcast).with()


          @game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
          @gu_1 = @game.games_users.first
          @current_user = @gu_1.user
          @card_being_updated = @gu_1.starting_card
          @description_text = 'user uploads first card description text'

          set_signed_cookies({user_id: @current_user.id})

          post in_game_card_uploads_path, params: { card: { description_text: @description_text } ,  format: :js}
        end
      end

      context 'drawing card'
    end

    context 'user uploads a non final card' do
      context 'drawing card' do
        before do
          @game = FactoryBot.create :midgame, callback_wanted: :midgame
          @gu_1, @gu_2 = @game.games_users
          @current_user = @gu_2.user
          @card_being_updated = @gu_1.starting_card.child_card

          set_signed_cookies({user_id: @current_user.id})

          @file_name = 'Ace_of_Diamonds.jpg'
          @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")

          post in_game_card_uploads_path, params: {
                                                    card: {
                                                            drawing_image: @drawn_image
                                                          },
                                                    format: :js
                                                  }
          @gu_2.reload
          @current_user.reload
          @card_being_updated.reload
        end

        it 'which updates the placeholder card that was created at the start of the game', :r5 do
          # byebug
          expect(@card_being_updated.drawing?).to eq true
          expect(@card_being_updated.description_text).to eq nil
          expect(@card_being_updated.idea_catalyst_id).to eq nil
          expect(@card_being_updated.starting_games_user_id).to eq @gu_1.id
          expect(@card_being_updated.uploader_id).to eq @current_user.id
          expect(@card_being_updated.placeholder).to eq false
          expect(@card_being_updated.out_of_game_card_upload).to eq false
          expect(@card_being_updated.drawing.attached?).to eq true
        end

        it 'has set up the placeholder for the next player in the passing order', :r5_wip do
          card_being_updateds_child_card = @card_being_updated.child_card
          expect(card_being_updateds_child_card).to be_a Card
          expect(card_being_updateds_child_card.drawing.attached?).to eq false

          game_passing_order = JSON.parse(@game.passing_order)
          current_user_index = game_passing_order.index(@current_user.id)
          next_player_index = (current_user_index + 1) % @game.users.count
          expect(card_being_updateds_child_card.uploader_id).to eq game_passing_order[next_player_index]
          expect(card_being_updateds_child_card.description?).to eq true
        end

        it 'parent is of the correct type and is completed card of opposite type'do
          card_being_updated_parent_card = card_being_updated.parent_card

          expect(@card_being_updated_parent_card.id).to eq @gu_2.starting_card.id
          expect(@card_being_updated_parent_card.drawing.attached?).to eq false
          expect(@card_being_updated_parent_card.description?).to eq true
          expect(@card_being_updated_parent_card.description_text).to be_a String
          expect(@card_being_updated_parent_card.placeholder).to be_a false
        end

        it 'doesnt have a completed games_user set', :r5_wip do
          expect(@gu_2.set_complete).to eq false
        end

        it 'returned correct status code', :r5_wip do
          expect(response).to have_http_status :ok
        end

        it 'broadcasts the correct message to other users' do

        end
      end

      context 'description card'
    end

    context 'user uploads a final card', :r5_wip do
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

        it 'which updates the placeholder card that was created at the start of the game' do
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
