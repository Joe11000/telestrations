require 'rails_helper'
require 'support/login'

RSpec.describe RendezvousController, type: :request do
  include LoginHelper

  def set_signed_cookies params={}
    signed_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar

    params.each do |key, value|
      signed_cookies.signed[key.to_sym] = value
      cookies[key.to_sym] = signed_cookies[key.to_sym]
    end

    cookies
  end

  shared_examples_for "redirect user elsewhere if they shouldn't be on rendezvous page" do
    context 'user NOT logged in' do
      it 'redirects them back to home page' do
        set_signed_cookies({user_id: nil})

        expect( get rendezvous_choose_game_type_page_path ).to redirect_to(login_path)
      end
    end

    context 'user currently midgame' do
      it 'redirect user back to game they are playing' do
        set_signed_cookies({user_id: FactoryBot.create(:game, :midgame_with_no_moves).users.first.id})

        expect( get rendezvous_choose_game_type_page_path ).to redirect_to(game_path)
      end
    end
  end

  context '#choose_game_type_page', :r5 do
    it_behaves_like "redirect user elsewhere if they shouldn't be on rendezvous page"

    context 'user logged in' do
      before :each do
        @game = FactoryBot.create(:game, :pregame)
        @user = @game.users.first

        set_signed_cookies({ user_id: @user.id })

        get rendezvous_choose_game_type_page_path
      end

      it 'default layout is' do
        expect(response.body).to match(/logout/)
        expect(response.body).to match(/#{@user.name}/)
        expect(response.body).to match(/Play Game/)
        expect(response.body).to match(/Create a New Game/)
        expect(response.body).to match(/Join a Public or Private Game/)
        expect(response.body).to match(/Join a Public or Private Game/)
        expect(response.body).to match(/Upload Cards/)
        expect(response.body).to match(/Save Drawings From Games You\'ve Played at Home/)
      end

      it 'has correct response status' do
        expect(response).to have_http_status :ok
      end
    end
  end

  context '#join_game', :r5 do
    it_behaves_like "redirect user elsewhere if they shouldn't be on rendezvous page"

    context 'game/rendezvous/join' do
      context 'One game exists with matching :join_code', :r5 do
        it 'user can join a public game'  do
          FactoryBot.create(:game, :pregame, :public_game)
          game = FactoryBot.create(:game, :pregame, :public_game)
          current_user = FactoryBot.create(:user)
          set_signed_cookies({user_id: current_user.id})

          post join_game_path, params: {join_code: game.join_code}

          game.reload
          current_user.reload

          expect(response).to redirect_to(rendezvous_page_path('public'))
        end

        it 'user can join a private game' do
          FactoryBot.create(:game, :pregame, :private_game)
          game = FactoryBot.create(:game, :pregame, :private_game)
          current_user = FactoryBot.create(:user)
          set_signed_cookies({user_id: current_user.id})

          post join_game_path, params: {join_code: game.join_code}

          game.reload
          current_user.reload

          expect(response).to redirect_to(rendezvous_page_path('private'))
        end
      end


      context 'NO games exist with that join_code', :r5 do
        it 'user is redirected to the same page with an alert message', :r5 do
          invalid_join_code = 'abc1'
          current_user = FactoryBot.create(:user)
          set_signed_cookies({ user_id: current_user.id })


          post join_game_path, params: { join_code: invalid_join_code }

          expect(response).to redirect_to(rendezvous_choose_game_type_page_path)
          expect(flash.alert).to eq "Group #{invalid_join_code} doesn't exist."
        end
      end
    end
  end

  context '#rendezvous_page' do
    it_behaves_like "redirect user elsewhere if they shouldn't be on rendezvous page"

    context 'a logged in user can visit' do
      context '/rendezvous/public' do
        context 'if NOT currently associated with any other games', :r5 do
          it 'creates a newly created public game' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            expect{ get rendezvous_page_path('public')}.to change{Game.count}.by(1)
            expect(Game.last.public_game?).to eq true
          end

          it 'has correct status' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get rendezvous_page_path('public')

            expect(response).to have_http_status :ok
          end


          it 'sees content expected to be seen on the page, (reminder: the current user until after the rendezvous channel subscribe method creates a games_user join connection)' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get rendezvous_page_path('public')

            expect(response.body).to match(/Leave Group/)
            expect(response.body).to match(/Join Code : .*>#{Game.last.join_code}</)

            expect(response.body).to match(/Join This Public Game/)

            expect(response.body).to match(/Users Not Joined \( 0 \)/) # current user not counted in this number until after the rendezvous channel subscribe method establishes a games_user join connection
            expect(response.body).to match(/Users Joined \( 0 \)/)
          end
        end

        context 'if user wants to leave game and join a different game type and does so by editing the search bar or using browser back arrow', :r5 do
          context 'leaving a private pregame to join a public game' do
            it "removes user's games_user association to previous game and displays new private game", :r5 do
              other_game = FactoryBot.create(:game, :pregame, :private_game)
              current_user = other_game.users.first
              set_signed_cookies({ user_id: current_user.id })

              get rendezvous_page_path('public')

              current_user.reload
              other_game.reload

              expect(other_game.user_ids).not_to include current_user.id
              last_game = Game.last

              expect(last_game.id).not_to eq other_game.id
              expect(last_game.user_ids).not_to include current_user.id
              expect(last_game.public_game?).to eq true

              expect(current_user.current_game).to eq nil # the user is not associated to the game when they land on the page they are attached to game through the subscribe method on the rendezvous channel
            end
          end
        end

        context 'user refreshes the page on rendezous page', :r5 do
          context 'and user has not chosen a game name yet' do
            it 'then user should still see the join code they were looking at before' do
              FactoryBot.create(:game, :pregame, :public_game)

              game = FactoryBot.create(:game, :pregame, :public_game)
              current_user = game.users.first
              set_signed_cookies({user_id: current_user.id})

              get rendezvous_page_path('public')

              game.reload
              current_user.reload

              expect(current_user.current_game.id).to eq game.id

              expect(response.body).to match(/Join This Public Game/)
              expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
            end
          end

          context 'user has chosen a game name', :r5 do
            it 'then user should still see the join code they were looking at before' do
                FactoryBot.create(:game, :pregame, :public_game)
                FactoryBot.create(:game, :pregame, :private_game)

                game = FactoryBot.create(:game, :pregame, :public_game)
                current_user = game.users.first
                set_signed_cookies({user_id: current_user.id})

                get rendezvous_page_path('public')

                game.reload
                current_user.reload

                expect(current_user.current_game.id).to eq game.id

                expect(response.body).to match(/Join This Public Game/)
                expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
                expect(response.body).to match(/Users Joined .*>#{current_user.current_games_user_name}</)
            end
          end
        end
      end

      context '/rendezvous/private' do
        context 'if NOT currently associated with any other games', :r5 do
          it 'creates a newly created private game' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            expect{ get rendezvous_page_path('private')}.to change{Game.count}.by(1)
            expect(Game.last.private_game?).to eq true
          end

          it 'has correct status' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get rendezvous_page_path('private')

            expect(response).to have_http_status :ok
          end


          it 'sees content expected to be seen on the page, (reminder: the current user until after the rendezvous channel subscribe method creates a games_user join connection)' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get rendezvous_page_path('private')

            expect(response.body).to match(/Leave Group/)
            expect(response.body).to match(/Join Code : .*>#{Game.last.join_code}</)

            expect(response.body).to match(/Join This Private Game/)

            expect(response.body).to match(/Users Not Joined \( 0 \)/) # current user not counted in this number until after the rendezvous channel subscribe method establishes a games_user join connection
            expect(response.body).to match(/Users Joined \( 0 \)/)
          end
        end

        context 'if user wants to leave game and join a different game type and does so by editing the search bar or using browser back arrow', :r5 do
          context 'leaving a public pregame to join a private game' do
            it "removes user's games_user association to previous game and displays new private game", :r5_wip do
              other_game = FactoryBot.create(:game, :pregame, :public_game)
              current_user = other_game.users.first
              set_signed_cookies({ user_id: current_user.id })

              get rendezvous_page_path('private')

              current_user.reload
              other_game.reload

              expect(other_game.user_ids).not_to include current_user.id

              last_game = Game.last
              expect(last_game.id).not_to eq other_game.id
              expect(last_game.user_ids).not_to include current_user.id
              expect(last_game.private_game?).to eq true

              expect(current_user.current_game).to eq nil # the user is not associated to the game when they land on the page they are attached to game through the subscribe method on the rendezvous channel
            end
          end
        end

        context 'user refreshes the page', :r5 do
          context 'and user has not chosen a game name yet' do
            it 'then user should still see the join code they were looking at before' do
              FactoryBot.create(:game, :pregame, :private_game)

              game = FactoryBot.create(:game, :pregame, :private_game)
              current_user = game.users.first
              set_signed_cookies({user_id: current_user.id})

              get rendezvous_page_path('private')

              game.reload
              current_user.reload

              expect(current_user.current_game.id).to eq game.id

              expect(response.body).to match(/Join This Private Game/)
              expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
            end
          end

          context 'and user has chosen a game name' do
            it 'then user should still see the join code they were looking at before' do
                FactoryBot.create(:game, :pregame, :private_game)
                FactoryBot.create(:game, :pregame, :public_game)

                game = FactoryBot.create(:game, :pregame, :private_game)
                current_user = game.users.first
                set_signed_cookies({user_id: current_user.id})

                get rendezvous_page_path('private')

                game.reload
                current_user.reload

                expect(current_user.current_game.id).to eq game.id
                expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
                expect(response.body).to match(/Users Joined .*>#{current_user.current_games_user_name}</)
            end
          end
        end
      end

      context '/rendezvous/quick_start', :r5_wip do
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

  xcontext '#leave_group' , current: true do
    it_behaves_like "redirect user elsewhere if they shouldn't be on rendezvous page"

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
          game = FactoryBot.create(:game, :pregame, :public_game)
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
          game = FactoryBot.create(:game, :pregame, :public_game)
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
