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

    context 'user uploads first card', :r5_wip do
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
        end

        it 'has set up the placeholder for the next player in the passing order' do
          expect(@card_being_updated.description_text).to eq @description_text
          expect(@card_being_updated.child_card).to be_a Card
          expect(@card_being_updated.child_card.drawing?).to eq true
          expect(@card_being_updated.child_card.drawing.attached?).to eq false

          game_passing_order = JSON.parse(@game.passing_order)
          current_user_index = game_passing_order.index(@current_user.id)
          next_player_index = (current_user_index + 1) % @game.users.count
          expect(@card_being_updated.child_card.uploader_id).to eq game_passing_order[next_player_index]
        end

        it 'returned correct status code' do
          expect(response).to have_http_status :ok
        end

        it 'broadcasts the correct message to other users' do

        end
      end

      xcontext 'drawing card' do
      end
    end

    context 'user uploads a non final card' do
      context 'drawing'
      context 'description'
    end

    context 'user uploads a final card' do
      context 'drawing'
      context 'description'
    end
  end
end
