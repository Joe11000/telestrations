require 'rails_helper'
require 'support/login'

RSpec.describe LobbiesController, type: :request do
  include LoginHelper

  shared_examples_for "redirect user elsewhere if they shouldn't be on lobby page" do
    context 'user NOT logged in' do
      it 'redirects them back to home page' do
        set_signed_cookies({user_id: nil})

        expect( get choose_game_type_page_path ).to redirect_to(login_path)
      end
    end

    context 'user currently midgame' do
      it 'redirect user back to game they are playing' do
        set_signed_cookies({user_id: FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves).users.first.id})

        expect( get choose_game_type_page_path ).to redirect_to(games_path)
      end
    end
  end

  context '#choose_game_type_page', :r5 do
    it_behaves_like "redirect user elsewhere if they shouldn't be on lobby page"

    context 'user logged in' do
      before :each do
        @game = FactoryBot.create(:pregame, callback_wanted: :pregame)
        @user = @game.users.first

        set_signed_cookies({ user_id: @user.id })

        get choose_game_type_page_path
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
    it_behaves_like "redirect user elsewhere if they shouldn't be on lobby page"

    context 'game/lobby/join' do
      context 'One game exists with matching :join_code' do
        it 'user can join a public game'  do
          FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
          game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
          current_user = FactoryBot.create(:user)
          set_signed_cookies({user_id: current_user.id})

          post join_lobby_path, params: {join_code: game.join_code}

          game.reload
          current_user.reload

          expect(response).to redirect_to(lobby_path('public'))
        end

        it 'user can join a private game' do
          FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
          game = FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
          current_user = FactoryBot.create(:user)
          set_signed_cookies({user_id: current_user.id})

          post join_lobby_path, params: {join_code: game.join_code}

          game.reload
          current_user.reload

          expect(response).to redirect_to(lobby_path('private'))
        end
      end


      context 'NO games exist with that join_code' do
        it 'user is redirected to the same page with an alert message' do
          invalid_join_code = 'abc1'
          current_user = FactoryBot.create(:user)
          set_signed_cookies({ user_id: current_user.id })


          post join_lobby_path, params: { join_code: invalid_join_code }

          expect(response).to redirect_to(choose_game_type_page_path)
          expect(flash.alert).to eq "Join Code #{invalid_join_code} doesn't exist."
        end
      end
    end
  end

  context '#lobby', :r5 do
    it_behaves_like "redirect user elsewhere if they shouldn't be on lobby page"

    context 'a logged in user can visit' do
      context '/lobby/public' do
        context 'if NOT currently associated with any other games' do
          it 'creates a newly created public game' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            expect{ get lobby_path('public')}.to change{Game.count}.by(1)
            expect(Game.last.public_game?).to eq true
          end

          it 'has correct status' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('public')

            expect(response).to have_http_status :ok
          end


          it 'sees content expected to be seen on the page, (reminder: the current user until after the lobby channel subscribe method creates a games_user join connection)' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('public')

            expect(response.body).to match(/Leave Group/)
            expect(response.body).to match(/Join Code : .*>#{Game.last.join_code}</)

            expect(response.body).to match(/Join This Public Game/)

            expect(response.body).to match(/Users Not Joined \( 0 \)/) # current user not counted in this number until after the lobby channel subscribe method establishes a games_user join connection
            expect(response.body).to match(/Users Joined \( 0 \)/)
          end
        end

        context 'if user wants to leave game and join a different game type and does so by editing the search bar or using browser back arrow' do
          context 'leaving a private pregame to join a public game' do
            it "removes user's games_user association to previous game and displays new private game" do
              other_game = FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
              current_user = other_game.users.first
              set_signed_cookies({ user_id: current_user.id })

              get lobby_path('public')

              current_user.reload
              other_game.reload

              expect(other_game.user_ids).not_to include current_user.id
              last_game = Game.last

              expect(last_game.id).not_to eq other_game.id
              expect(last_game.user_ids).not_to include current_user.id
              expect(last_game.public_game?).to eq true

              expect(current_user.current_game).to eq nil # the user is not associated to the game when they land on the page they are attached to game through the subscribe method on the lobby channel
            end
          end
        end

        context 'user refreshes the page on rendezous page' do
          context 'and user has not chosen a game name yet' do
            it 'then user should still see the join code they were looking at before' do
              FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

              game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
              current_user = game.users.first
              set_signed_cookies({user_id: current_user.id})

              get lobby_path('public')

              game.reload
              current_user.reload

              expect(current_user.current_game.id).to eq game.id

              expect(response.body).to match(/Join This Public Game/)
              expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
            end
          end

          context 'user has chosen a game name' do
            it 'then user should still see the join code they were looking at before' do
                FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
                FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)

                game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
                current_user = game.users.first
                set_signed_cookies({user_id: current_user.id})

                get lobby_path('public')

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

      context '/lobby/private' do
        context 'if NOT currently associated with any other games' do
          it 'creates a newly created private game' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            expect{ get lobby_path('private')}.to change{Game.count}.by(1)
            expect(Game.last.private_game?).to eq true
          end

          it 'has correct status' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('private')

            expect(response).to have_http_status :ok
          end


          it 'sees content expected to be seen on the page, (reminder: the current user until after the lobby channel subscribe method creates a games_user join connection)' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('private')

            expect(response.body).to match(/Leave Group/)
            expect(response.body).to match(/Join Code : .*>#{Game.last.join_code}</)

            expect(response.body).to match(/Join This Private Game/)

            expect(response.body).to match(/Users Not Joined \( 0 \)/) # current user not counted in this number until after the lobby channel subscribe method establishes a games_user join connection
            expect(response.body).to match(/Users Joined \( 0 \)/)
          end
        end

        context 'if user wants to leave game and join a different game type and does so by editing the search bar or using browser back arrow' do
          context 'leaving a public pregame to join a private game' do
            it "removes user's games_user association to previous game and displays new private game" do
              other_game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
              current_user = other_game.users.first
              set_signed_cookies({ user_id: current_user.id })

              get lobby_path('private')

              current_user.reload
              other_game.reload

              expect(other_game.user_ids).not_to include current_user.id

              last_game = Game.last
              expect(last_game.id).not_to eq other_game.id
              expect(last_game.user_ids).not_to include current_user.id
              expect(last_game.private_game?).to eq true

              expect(current_user.current_game).to eq nil # the user is not associated to the game when they land on the page they are attached to game through the subscribe method on the lobby channel
            end
          end
        end

        context 'user refreshes the page' do
          context 'and user has not chosen a game name yet' do
            it 'then user should still see the join code they were looking at before' do
              FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)

              game = FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
              current_user = game.users.first
              set_signed_cookies({user_id: current_user.id})

              get lobby_path('private')

              game.reload
              current_user.reload

              expect(current_user.current_game.id).to eq game.id

              expect(response.body).to match(/Join This Private Game/)
              expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
            end
          end

          context 'and user has chosen a game name' do
            it 'then user should still see the join code they were looking at before' do
                FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

                game = FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                current_user = game.users.first
                set_signed_cookies({user_id: current_user.id})

                get lobby_path('private')

                game.reload
                current_user.reload

                expect(current_user.current_game.id).to eq game.id
                expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
                expect(response.body).to match(/Users Joined .*>#{current_user.current_games_user_name}</)
            end
          end
        end
      end

      context '/lobby/quick_start' do

        context 'if NOT currently associated with any other games' do

          it 'creates a newly created public game if none exist' do
            current_user = FactoryBot.create(:user)
            FactoryBot.create :pregame, :private_game, callback_wanted: :pregame
            set_signed_cookies({ user_id: current_user.id })

            expect{ get lobby_path('quick_start')}.to change{Game.count}.by(1)
            expect(Game.last.public_game?).to eq true
            expect(response.body).to match(/Join This Public Game/)
          end

          it 'returns a random public pregame if one exists' do
            current_user = FactoryBot.create(:user)
            FactoryBot.create :pregame, :private_game, callback_wanted: :pregame
            FactoryBot.create :midgame, :public_game, callback_wanted: :midgame
            game = FactoryBot.create :pregame, :public_game, callback_wanted: :pregame

            set_signed_cookies({ user_id: current_user.id })

            expect{ get lobby_path('quick_start')}.to change{Game.count}.by(0)
            expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
            expect(response.body).to match(/Join This Public Game/)
          end

          it 'has correct status' do
            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('quick_start')

            expect(response).to have_http_status :ok
          end


          it 'sees content expected to be seen on the page, (reminder: the current user until after the lobby channel subscribe method creates a games_user join connection)' do

            current_user = FactoryBot.create(:user)
            set_signed_cookies({ user_id: current_user.id })

            get lobby_path('quick_start')

            expect(response.body).to match(/Leave Group/)
            expect(response.body).to match(/Join Code : .*>#{Game.last.join_code}</)

            expect(response.body).to match(/Join This Public Game/)

            expect(response.body).to match(/Users Not Joined \( 0 \)/) # current user not counted in this number until after the lobby channel subscribe method establishes a games_user join connection
            expect(response.body).to match(/Users Joined \( 0 \)/)
          end
        end

        context 'if currently associated with a game' do
          context 'if user wants to leave a game and join a different game type and does so by editing the search bar or using browser back arrow' do
            context 'leaving a private pregame to join a quick_start .... which is a public game' do
              it "removes user's games_user association to previous game and displays" do
                # Game.destroy_all
                other_game = FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                current_user = other_game.users.first
                set_signed_cookies({ user_id: current_user.id })

                get lobby_path('quick_start')

                current_user.reload
                other_game.reload

                expect(other_game.user_ids).not_to include current_user.id
                last_game = Game.last

                expect(last_game.id).not_to eq other_game.id
                expect(last_game.user_ids).not_to include current_user.id
                expect(last_game.public_game?).to eq true

                expect(current_user.current_game).to eq nil # the user is not associated to the game when they land on the page they are attached to game through the subscribe method on the lobby channel
              end
            end
          end

          context 'user refreshes the page on rendezous page' do
            context 'if this is the only public pregames that exists' do
              context 'then it should not create another one and view it' do
                context 'and user has not chosen a game name yet' do
                  it 'then user should still see the join code they were looking at before' do
                    FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
                    FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                    game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

                    current_user = game.users.first
                    set_signed_cookies({user_id: current_user.id})

                    get lobby_path('quick_start')

                    game.reload
                    current_user.reload
                    expect(current_user.current_game.id).to eq game.id

                    expect(response.body).to match(/Join This Public Game/)
                    expect(response.body).to match(/Join Code : .*>#{game.join_code}</)
                  end
                end

                context 'user has chosen a game name' do
                  it 'then user should still see the join code they were looking at before' do
                    FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
                    FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                    game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

                    current_user = game.users.first
                    set_signed_cookies({user_id: current_user.id})

                    get lobby_path('quick_start')

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

            context 'if multiple public pregames exist' do
              context "it should show only public game" do
                context 'then it should not create another one and view it' do
                  context 'and user has not chosen a game name yet' do
                    it 'then user should still see the join code they were looking at before' do
                      FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
                      FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                      game1 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
                      game2 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

                      current_user = game1.users.first
                      set_signed_cookies({user_id: current_user.id})

                      get lobby_path('quick_start')

                      game1.reload
                      current_user.reload
                      expect(current_user.current_game.id).to eq game1.id

                      expect(response.body).to match(/Join This Public Game/)
                      expect(response.body).to match(/Join Code : .*>#{game1.join_code}|#{game2.join_code}</)
                    end
                  end

                  context 'user has chosen a game name' do
                    it 'then user should still see the join code they were looking at before' do
                      FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
                      FactoryBot.create(:pregame, :private_game, callback_wanted: :pregame)
                      game1 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
                      game2 = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)

                      current_user = game1.users.first
                      set_signed_cookies({user_id: current_user.id})

                      get lobby_path('quick_start')

                      game1.reload
                      current_user.reload

                      expect(current_user.current_game.id).to eq game1.id

                      expect(response.body).to match(/Join This Public Game/)
                      expect(response.body).to match(/Join Code : .*>#{game1.join_code}|#{game2.join_code}</)
                    end
                  end
                end

              end
            end
          end
        end
      end
    end
  end

  # context '#leave_group', :r5 do
  #   it_behaves_like "redirect user elsewhere if they shouldn't be on lobby page"

  #   context 'user leaving IS the only one attached to the game' do
  #     it 'removes user from game before redirecting user to choose_game_type_page' do
  #       game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
  #       game_id = game.id
  #       game.users.limit(game.users.count - 1).destroy_all
  #       current_user = game.users.first
  #       set_signed_cookies({user_id: current_user.id})

  #       get leave_pregame_path

  #       expect(Game.find_by(id: game_id)).to eq nil
  #       expect(response).to redirect_to(choose_game_type_page_path)
  #     end
  #   end

  #   context 'user leaving IS NOT the only one attached to the game' do
  #     it 'removes user from game before redirecting user to choose_game_type_page' do
  #       game = FactoryBot.create(:pregame, :public_game, callback_wanted: :pregame)
  #       game_id = game.id
  #       current_user = game.users.first
  #       remaining_user_ids = game.user_ids - [current_user.id]
  #       set_signed_cookies({user_id: current_user.id})

  #       get leave_pregame_path

  #       expect(Game.find_by(id: game_id).user_ids).to match_array remaining_user_ids
  #       expect(response).to redirect_to(choose_game_type_page_path)
  #     end
  #   end
  # end
end
