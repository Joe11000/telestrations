require 'rails_helper'

RSpec.describe GamesController, :type => :request do

  describe "GET game_page", working: true do

    context 'redirected if' do
      it 'user not logged in' do
        get :game_page

        expect(response).to redirect_to login_path
      end

      it 'no current user game' do
        game = FactoryBot.create(:midgame_without_cards)
        user = FactoryBot.create(:user)
        cookies.signed[:user_id] = user.id

        get :game_page

        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == pregame' do
        game = FactoryBot.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :game_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == postgame' do
        game = FactoryBot.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :game_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end
    end

    context 'renders correct variables to page' do
      it "person first lands on game_page" do
        game = FactoryBot.create(:midgame_without_cards)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        expect do
          get :game_page
        end.to change{Card.count}.by(1)

        expect(assigns[:game]).to eq game
        expect(assigns[:placeholder_card]).to eq current_user.current_starting_card
        expect(assigns[:prev_card]).to eq Card.none
        expect(assigns[:current_user]).to eq current_user
        expect(response).to have_http_status(:success)
      end

      it "person refreshes page during game" do
        game = FactoryBot.create(:midgame)
        gu = game.games_users.order(:id).second
        find_card = gu.starting_card.child_card
        current_user = find_card.uploader
        cookies.signed[:user_id] = current_user.id

        expect do
          get :game_page
        end.to change{Card.count}.by(0)

        expect(assigns[:game]).to eq game
        expect(assigns[:placeholder_card]).to eq find_card
        expect(assigns[:prev_card]).to eq find_card.parent_card
        expect(assigns[:current_user]).to eq current_user
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET postgame_page", working: true do

    context 'redirected if' do
      it 'user not logged in' do
        get :postgame_page

        expect(response).to redirect_to login_path
      end

      it 'no current user game' do
        game = FactoryBot.create(:postgame)
        user = FactoryBot.create(:user)
        cookies.signed[:user_id] = user.id

        get :postgame_page

        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == pregame' do
        game = FactoryBot.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :postgame_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == midgame' do
        game = FactoryBot.create(:midgame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :postgame_page
        expect(response).to redirect_to game_page_path
      end
    end

    it 'has correct variables being displayed on the page', wip: true do
      game = FactoryBot.create(:postgame)
      current_user = game.users.order(:id).first
      cookies.signed[:user_id] = current_user.id

      expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

      get :postgame_page

      expect(assigns[:game]).to eq game
      expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
      expect(assigns[:current_user]).to eq current_user
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET all_postgames_page", working: true do

    context 'redirected if' do
      it 'user not logged in' do
        get :postgame_page

        expect(response).to redirect_to login_path
      end

      it 'current game.status == midgame' do
        game = FactoryBot.create(:midgame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :postgame_page
        expect(response).to redirect_to game_page_path
      end
    end

    it 'has correct variables being displayed on the page', wip: true do
      game = FactoryBot.create(:postgame)
      current_user = game.users.order(:id).first
      cookies.signed[:user_id] = current_user.id
      card_to_find_1 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
      card_to_find_2 = FactoryBot.create(:description, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
      expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

      get :all_postgames_page

      expect(assigns[:out_of_game_cards]).to eq [ card_to_find_1, card_to_find_2 ]
      expect(assigns[:current_user]).to eq current_user
      expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
      expect(response).to have_http_status(:success)
    end
  end
end
