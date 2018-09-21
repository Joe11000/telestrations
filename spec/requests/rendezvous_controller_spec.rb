require 'rails_helper'

RSpec.describe RendezvousController, type: :request do

  shared_examples_for "redirect user to root if not logged in" do
    context 'user NOT logged in' do
      it 'redirects them back to home page' do
        byebug
        controller.session.clear
        get :choose_game_type_page

        expect(response).to redirect_to(login_path)
      end
    end
  end

  context '#choose_game_type_page' do
    it_behaves_like "redirect user to root if not logged in"

    context 'user logged in' do
      it 'default layout is' do
        controller.session[:user_id] = FactoryBot.create(:user).id
        get :choose_game_type_page

        expect(response).to render_template(:choose_game_type_page)
        expect(response).to render_template('layouts/application')
      end

      it 'has correct response status' do
        controller.session[:user_id] = FactoryBot.create(:user).id
        get :choose_game_type_page

        expect(response.status).to eq(200)
      end
    end
  end

  context '#join_game', wip: true do
    it_behaves_like "redirect user to root if not logged in"

    context 'game/rendezvous/join' do
      context 'One game exists with matching :join_code' do
        it 'user can join a public game' do
          game = FactoryBot.create(:public_pregame)
          current_user = game.users.first
          controller.session[:user_id] = current_user.id

          post :join_game, join_code: game.join_code

          game.reload
          current_user.reload

          expect(assigns[:user_already_joined].id).to eq false
          expect(assigns[:game].id).to eq game.id
          expect(assigns[:game].try(:game_type)).to eq 'public'
          expect(assigns[:users_waiting]).to eq game.users.map(&:current_games_user_name)
        end

        it 'user can join a private game' do
          game = FactoryBot.create(:public_pregame, is_private: true)
          current_user = game.users.first
          controller.session[:user_id] = current_user.id

          post :join_game, join_code: game.join_code

          game.reload
          current_user.reload

          expect(assigns[:game].id).to eq game.id
          expect(assigns[:game].try(:game_type)).to eq 'private'
          expect(assigns[:users_waiting]).to eq game.users.map(&:current_games_user_name)
        end

        it 'renders the correct page' do
          game = FactoryBot.create(:public_pregame)
          current_user = game.users.first
          controller.session[:user_id] = current_user.id

          post :join_game, join_code: game.join_code

          expect(response).to render_template(:rendezvous_page)
        end
      end


      context 'NO games exist with that join_code' do
        # render_views

        it 'user is redirected to the same page with an alert message', future_test: true do
          Game.destroy_all

          invalid_join_code = 'abcd'
          current_user = FactoryBot.create(:user)
          controller.session[:user_id] = current_user.id

          post :join_game, join_code: invalid_join_code

          expect(response).to redirect_to(rendezvous_choose_game_type_page_path)
          expect(flash.alert).to eq "No players in group #{invalid_join_code}"
          # expect(response.body).to match /No players in group #{invalid_join_code}/im   !!future_fix
        end
      end
    end
  end

  context '#rendezvous_page' do
    it_behaves_like "redirect user to root if not logged in"

    context 'user logged in' do
      context '/rendezvous/public' do

        it 'layout in this case is' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'public'

          expect(response).to render_template(:rendezvous_page)
          expect(response).to render_template('layouts/application')
        end

        it 'has correct variabels assigned' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'public'

          # private game created
          expect(assigns[:game].try(:is_private)).to eq false

          # has no users waiting in rendezvous
          expect(assigns[:users_waiting]).to eq []
        end

        it 'has correct response status' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'public'

          expect(response.status).to eq(200)
        end
      end

      context '/rendezvous/private' do
        it 'layout in this case is' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'private'

          expect(response).to render_template(:rendezvous_page)
          expect(response).to render_template('layouts/application')
        end

        it 'has correct variabels assigned' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'private'

          # private game created
          expect(assigns[:game].try(:is_private)).to eq true

          # has no users waiting in rendezvous
          expect(assigns[:users_waiting]).to eq []
        end

        it 'has correct response status' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'private'

          expect(response.status).to eq(200)
        end
      end

      context '/rendezvous/quick_start' do
        it 'layout in this case is' do
          controller.session[:user_id] = FactoryBot.create(:user).id
          get :rendezvous_page, game_type: 'quick_start'

          expect(response).to render_template(:rendezvous_page)
          expect(response).to render_template('layouts/application')
        end

        context 'has correct variables assigned' do
          it 'a public game exists with a player in it' do
            Game.destroy_all

            user = FactoryBot.create(:user)
            game = FactoryBot.create(:game, is_private: false)
            user.games << game
            controller.session[:user_id] = FactoryBot.create(:user).id

            get :rendezvous_page, game_type: 'quick_start'

            game.reload
            user.reload

            expect(assigns[:game].id).to eq game.id
            expect(assigns[:game].try(:is_private)).to eq false # public game created
            expect(assigns[:users_waiting]).to eq game.users.map(&:current_games_user_name) # has a user waiting in rendezvous
            expect(response.status).to eq(200)
          end

          it 'NO public games exist, then make one and continue to rendezvous page' do
            Game.destroy_all
            current_user = FactoryBot.create(:user)
            controller.session[:user_id] = current_user.id

            expect{
              get :rendezvous_page, game_type: 'quick_start'
            }.to change{Game.count}.from(0).to(1)

            # public game created
            expect(assigns[:game]).to be_an_instance_of Game
            expect(assigns[:game].try(:is_private)).to eq false

            # has no users waiting in rendezvous
            expect(assigns[:users_waiting]).to eq []
          end
        end
      end
    end
  end

  context '#get_updates', current: true do
    # render_views

    it_behaves_like "redirect user to root if not logged in"

    it 'returns same partial if any users_game_names in the html of the players that are waiting to start the game' do
      controller.session[:user_id] = FactoryBot.create(:user).id
      @game = FactoryBot.create(:game)
      gu1 = FactoryBot.create(:games_user, game: @game)
      gu2 = FactoryBot.create(:games_user, game: @game)

      xhr :post, :get_updates, join_code: @game.join_code

      expect( JSON.parse(response.body)['content']).to match /data-id=\"currently-joined\"/
      expect( JSON.parse(response.body)['content']).to match /#{gu1.users_game_name}/
      expect( JSON.parse(response.body)['content']).to match /#{gu2.users_game_name}/
    end

    it 'returns same partial even if includes 0+ users_game_names in the html of the players that are waiting to start the game' do
      controller.session[:user_id] = FactoryBot.create(:user).id
      @game = FactoryBot.create(:game)

      xhr :post, :get_updates, join_code: @game.join_code

      expect( JSON.parse(response.body)['content'] ).to match /data-id=\"currently-joined\"/
    end
  end

  context '#update', js: true do
    # render_views

    it_behaves_like "redirect user to root if not logged in"

    it 'user can join a game', current: true do
      current_user = FactoryBot.create(:user)
      controller.session[:user_id] = current_user.id
      game = FactoryBot.create(:public_pregame)

      xhr :post, :update, join_code: game.join_code, users_game_name: Faker::Name.first_name

      current_user.reload

      expect(current_user.current_game).to eq game
      expect(JSON.parse(response.body)['response']).to eq 'user sucessfully joined'
      expect(response.status).to eq 200
    end

    it "user can't associate it's name with a game that doesn't exist" do
      Game.destroy_all
      current_user = FactoryBot.create(:user)
      controller.session[:user_id] = current_user.id
      invalid_join_code = 'aaaa'

      xhr :post, :update, join_code: invalid_join_code, users_game_name: Faker::Name.first_name

      current_user.reload
      expect(current_user.games.count).to eq 0
      expect(JSON.parse(response.body)['response']).to eq 'user unsucessfully joined'
      expect(response.status).to eq 200
    end


    it 'user is blocked from joining game twice' do
      game = FactoryBot.create(:public_pregame)
      current_user = game.users.first
      controller.session[:user_id] = current_user.id

      xhr :post, :update, join_code: game.join_code, users_game_name: Faker::Name.first_name

      current_user.reload
      expect(current_user.games.ids).to eq [game.id]
      expect(JSON.parse(response.body)['response']).to eq 'user already joined'
      expect(response.status).to eq 200
    end

    it "user can be removed from another pre-game game" do
      game = FactoryBot.create(:public_pregame)
      current_user = game.users.first
      controller.session[:user_id] = current_user.id

      game2 = FactoryBot.create(:public_pregame)

      xhr :post, :update, join_code: game2.join_code, users_game_name: Faker::Name.first_name

      current_user.reload
      expect(current_user.games.ids).to eq [game2.id]
      expect(JSON.parse(response.body)['response']).to eq 'user sucessfully joined'
      expect(response.status).to eq 200
    end

    it "user can't be removed from an in progress game" do
      game = FactoryBot.create(:midgame)
      current_user = game.users.first
      controller.session[:user_id] = current_user.id

      join_code_of_game_i_cant_join = FactoryBot.create(:public_pregame).join_code

      xhr :post, :update, join_code: join_code_of_game_i_cant_join, users_game_name: Faker::Name.first_name

      current_user.reload
      expect(current_user.games.ids).to eq [game.id]
      expect(current_user.current_game).to eq game
      expect(JSON.parse(response.body)['response']).to eq 'user currently involved in another game'
      expect(response.status).to eq 200
    end
  end

  context '#leave_group' , current: true do
    it_behaves_like "redirect user to root if not logged in"

    context 'user NOT currently associated with this game' do
      it 'redirects user to choose_game_type_page' do
        game = FactoryBot.create(:game)
        current_user = FactoryBot.create(:user)
        controller.session[:user_id] = current_user.id
        get :leave_pregame, join_code: game.join_code

        game.reload
        expect(game.deleted?).to eq false
        expect(game.users.ids).to eq []
        expect(response).to redirect_to(:rendezvous_choose_game_type_page)
      end
    end

    context 'user IS currently associated with game' do
      context 'and is the only one attached to the game' do
        it 'removes user from game before redirecting user to choose_game_type_page' do
          game = FactoryBot.create(:public_pregame)
          current_user = game.users.first
          game.users.where.not(id: current_user.id).destroy_all
          controller.session[:user_id] = current_user.id
          get :leave_pregame, join_code: game.join_code

          game.reload
          expect(game.users.find_by(id: current_user.id)).to eq nil
          expect(game.users.ids).to eq []
          expect(game.deleted?).to eq false
          expect(response).to redirect_to(:rendezvous_choose_game_type_page)
        end
      end
      context 'and is one of many users attached to the game' do
        it 'removes user from game before redirecting user to choose_game_type_page' do
          game = FactoryBot.create(:public_pregame)
          current_user = game.users.first
          other_players_ids = game.users.where.not(id: current_user.id).ids
          controller.session[:user_id] = current_user.id
          get :leave_pregame, join_code: game.join_code

          game.reload
          expect(game.users.find_by(id: current_user.id)).to eq nil
          expect(game.users.where.not(id: current_user.id).ids).to eq other_players_ids
          expect(game.deleted?).to eq false
          expect(response).to redirect_to(:rendezvous_choose_game_type_page)
        end
      end
    end
  end
end
