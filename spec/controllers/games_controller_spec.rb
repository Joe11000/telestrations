require 'rails_helper'

RSpec.describe GamesController, :type => :controller do

  describe "GET game_page", working: true do

    context 'redirected if' do
      it 'user not logged in' do
        get :game_page

        expect(response).to redirect_to login_path
      end

      it 'no current user game' do
        game = FactoryGirl.create(:midgame_without_cards)
        user = FactoryGirl.create(:user)
        cookies.signed[:user_id] = user.id

        get :game_page

        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == pregame' do
        game = FactoryGirl.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :game_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == postgame' do
        game = FactoryGirl.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :game_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end
    end

    context 'renders correct variables to page' do
      it "person first lands on game_page" do
        game = FactoryGirl.create(:midgame_without_cards)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        expect do
          get :game_page
        end.to change{Card.count}.by(1)

        expect(assigns[:game]).to eq game
        expect(assigns[:placeholder_card]).to eq current_user.starting_card_in_current_game
        expect(assigns[:prev_card]).to eq Card.none
        expect(assigns[:current_user]).to eq current_user
        expect(response).to have_http_status(:success)
      end

      it "person refreshes page during game" do
        game = FactoryGirl.create(:midgame)
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
        game = FactoryGirl.create(:postgame)
        user = FactoryGirl.create(:user)
        cookies.signed[:user_id] = user.id

        get :postgame_page

        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == pregame' do
        game = FactoryGirl.create(:public_pregame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :postgame_page
        expect(response).to redirect_to rendezvous_choose_game_type_page_path
      end

      it 'current game.status == midgame' do
        game = FactoryGirl.create(:midgame)
        current_user = game.users.order(:id).first
        cookies.signed[:user_id] = current_user.id

        get :postgame_page
        expect(response).to redirect_to game_page_path
      end
    end

    it 'has correct variables being displayed on the page', wip: true do
      game = FactoryGirl.create(:postgame)
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
end
