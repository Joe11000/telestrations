require 'rails_helper'
require 'support/login'

RSpec.describe GamesController, :type => :request do
  include LoginHelper

  shared_examples_for "redirect if user shouldn't be playing this game" do
    context 'user NOT logged in' do
      context "user doesn't exist" do
        it 'redirects them back to home page' do
          set_signed_cookies({user_id: nil})

          expect( get rendezvous_choose_game_type_page_path ).to redirect_to(login_path)
        end
      end
    end

    context "user exists and" do
      context 'user has no associated game' do
        it 'then is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:user).id})

          expect( get rendezvous_choose_game_type_page_path ).to redirect_to(rendezvous_choose_game_type_page_path)
        end
      end

      context 'user should be waiting for their game to start' do
        it 'then user is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:pregame, callback_wanted: :pregame).users.first.id})

          expect( get rendezvous_choose_game_type_page_path ).to redirect_to(rendezvous_choose_game_type_page_path)
        end
      end

      context 'user just finished their game' do
        it 'then user is redirected back to choose game screen' do
          set_signed_cookies({user_id: FactoryBot.create(:postgame, callback_wanted: :postgame).users.first.id})

          expect( get rendezvous_choose_game_type_page_path ).to redirect_to(rendezvous_choose_game_type_page_path)
        end
      end
    end
  end

  describe "GET game_page" do
    it_behaves_like "redirect if user shouldn't be playing this game"

    it 'user can see', :r5_wip do
      game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
      current_user = game.users.first
      set_signed_cookies({user_id: current_user.id})

      get game_page_path
      byebug
      expect(response).not_to have_http_status 302
    end

    # xcontext 'renders correct variables to page' do
    #   it "person first lands on game_page" do
    #     game = FactoryBot.create(:game, :midgame_with_no_moves)
    #     current_user = game.users.order(:id).first
    #     # cookies.signed[:user_id] = current_user.id

    #     expect do
    #       get game_page_path
    #     end.to change{Card.count}.by(1)

    #     expect(assigns[:game]).to eq game
    #     expect(assigns[:placeholder_card]).to eq current_user.current_starting_card
    #     expect(assigns[:prev_card]).to eq Card.none
    #     expect(assigns[:current_user]).to eq current_user
    #     expect(response).to have_http_status(:success)
    #   end

    #   it "person refreshes page during game" do
    #     game = FactoryBot.create(:game, :midgame)
    #     gu = game.games_users.order(:id).second
    #     find_card = gu.starting_card.child_card
    #     current_user = find_card.uploader
    #     cookies.signed[:user_id] = current_user.id

    #     expect do
    #       get game_page_path
    #     end.to change{Card.count}.by(0)

    #     expect(assigns[:game]).to eq game
    #     expect(assigns[:placeholder_card]).to eq find_card
    #     expect(assigns[:prev_card]).to eq find_card.parent_card
    #     expect(assigns[:current_user]).to eq current_user
    #     expect(response).to have_http_status(:success)
    #   end
    # end
  end

  # xdescribe "GET postgame_page", working: true do

  #   context 'redirected if' do
  #     it 'user not logged in' do
  #       get :postgame_page

  #       expect(response).to redirect_to login_path
  #     end

  #     it 'no current user game' do
  #       game = FactoryBot.create(:game, :postgame)
  #       user = FactoryBot.create(:user)
  #       cookies.signed[:user_id] = user.id

  #       get :postgame_page

  #       expect(response).to redirect_to rendezvous_choose_game_type_page_path
  #     end

  #     it 'current game.status == pregame' do
  #       game = FactoryBot.create(:game, :pregame, :public_game)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :postgame_page
  #       expect(response).to redirect_to rendezvous_choose_game_type_page_path
  #     end

  #     it 'current game.status == midgame' do
  #       game = FactoryBot.create(:game, :midgame)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :postgame_page
  #       expect(response).to redirect_to game_page_path
  #     end
  #   end

  #   it 'has correct variables being displayed on the page', wip: true do
  #     game = FactoryBot.create(:game, :postgame)
  #     current_user = game.users.order(:id).first
  #     cookies.signed[:user_id] = current_user.id

  #     expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

  #     get :postgame_page

  #     expect(assigns[:game]).to eq game
  #     expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
  #     expect(assigns[:current_user]).to eq current_user
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # xdescribe "GET all_postgames_page", working: true do

  #   context 'redirected if' do
  #     it 'user not logged in' do
  #       get :postgame_page

  #       expect(response).to redirect_to login_path
  #     end

  #     it 'current game.status == midgame' do
  #       game = FactoryBot.create(:game, :midgame)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :postgame_page
  #       expect(response).to redirect_to game_page_path
  #     end
  #   end

  #   it 'has correct variables being displayed on the page', wip: true do
  #     game = FactoryBot.create(:game, :postgame)
  #     current_user = game.users.order(:id).first
  #     cookies.signed[:user_id] = current_user.id
  #     card_to_find_1 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
  #     card_to_find_2 = FactoryBot.create(:description, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
  #     expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

  #     get :all_postgames_page

  #     expect(assigns[:out_of_game_cards]).to eq [ card_to_find_1, card_to_find_2 ]
  #     expect(assigns[:current_user]).to eq current_user
  #     expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
