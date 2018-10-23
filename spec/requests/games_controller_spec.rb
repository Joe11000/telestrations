require 'rails_helper'
require 'support/login'
require 'json'

RSpec.describe GamesController, :type => :request do
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

  describe "GET :new", :r5_wip do
    # 4 stages
    # context user drawing card
    # context user creating description
    # context user waiting for card
    # context user done and waiting for friends to finish


    it_behaves_like "redirect if user shouldn't be playing this game"

      before :all do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        @current_user = game.users.first
        set_signed_cookies({user_id: @current_user.id})

        get new_game_path
      end


        # 4 stages
    context '#get_status_for_user', :r5_wip do
      context 'returns successful message for a player midgame' do
        context 'returns correct user for message if' do
          context 'user has placeholder for a drawing card' do
            it 'user should be drawing a picture' do
                game = FactoryBot.create(:midgame, callback_wanted: :midgame)
                user_1, user_2, user_3 = game.users.order(id: :asc)
                current_user = user_2

                expected_response = {
                                      attention_users: [user_2.id],
                                      current_user_id: user_2.id,
                                      game_over: false,
                                      previous_card: {
                                                        medium: 'description',
                                                        description_text: game.get_placeholder_card(user_2.id).parent_card.description_text
                                                      },
                                      user_status: 'working_on_card'
                                    }

                set_signed_cookies({current_user_id: current_user.id})
                get new_games_path

            end

            context 'user should be writing a description' do
              it 'no previous card' do
                game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
                current_user = game.users.first

                expected_response = {
                                      attention_users: [current_user.id],
                                      current_user_id: current_user.id,
                                      game_over: false,
                                      user_status: 'working_on_card'
                                    }

                expect( game.get_status_for_user(current_user) ).to eq expected_response
              end

              it 'yes, previous card', :r5 do
                game = FactoryBot.create(:midgame, callback_wanted: :midgame)
                user_1, user_2, user_3 = game.users.order(id: :asc)
                gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
                current_user = user_2

                # user 2 has a drawing card at the moment, and needs to be on their next card for this test
                  gu_1.starting_card.child_card.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                                             content_type: 'image/jpg', \
                                                             filename: 'provider_avatar.jpg') # replace the placeholder card because it was easier than updating it with a new attachment
                  gu_1.starting_card.child_card.update(placeholder: false);



                current_user_placeholder_description = game.get_placeholder_card(current_user.id)
                previous_card = gu_3.starting_card.child_card

                drawing_url = rails_blob_path( previous_card.drawing, disposition: 'attachment')

                expected_response = {
                                      attention_users: [current_user.id],
                                      current_user_id: current_user.id,
                                      game_over: false,
                                      user_status: 'working_on_card',
                                      previous_card: {
                                         medium: 'drawing',
                                         drawing_url: drawing_url
                                       }
                                    }


                expect( game.get_status_for_user(current_user) ).to eq expected_response
              end
            end

            it 'after uploading a card a user has to wait for card to be passed to them' do
              game = FactoryBot.create(:midgame, callback_wanted: :midgame)
              user_1, user_2, user_3 = game.users.order(id: :asc)
              current_user = user_1

              expected_response = { attention_users: [current_user.id],
                                    current_user_id: current_user.id,
                                    game_over: false,
                                    user_status: 'waiting' }

              expect( game.get_status_for_user(current_user) ).to eq expected_response
            end

            it 'user_1 is finished, but user 3 has not' do
              # user 1 has the finished message while they wait for user 3 to finish
              game = FactoryBot.create(:postgame, callback_wanted: :postgame)
              gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

               # undo the 3rd user's final card
                game.midgame!
                gu_1.update(set_complete: false)
                final_card = gu_1.starting_card.child_card.child_card
                final_card.update(placeholder: true)

              user_1, user_2, user_3 = game.users.order(id: :asc)
              current_user = user_1

              # user 1 should see a message that he is done
              expected_response = { attention_users: [current_user.id],
                                    current_user_id: current_user.id,
                                    game_over: false,
                                    user_status: 'finished' }
                byebug
              expect( game.get_status_for_user(current_user) ).to eq expected_response
            end


            it 'game_over when all players are finished' do
              game = FactoryBot.create(:postgame, callback_wanted: :postgame)
              gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)

              game.midgame!

              user_1_id, user_2_id, user_3_id = gu_1.user_id, gu_2.user_id, gu_3.user_id
              current_user = gu_1.user

              expected_response = { attention_users: [user_1_id, user_2_id, user_3_id],
                                    current_user_id: user_1_id,
                                    game_over: true,
                                    url_redirect: game_path(game.id) } # last player finishes

              expect( game.get_status_for_user(current_user) ).to eq expected_response
            end
          end
        end
      end
      xcontext 'returns unsuccessfully for a player not in midgame' do
        it 'game is a pregame' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          current_user = game.users.first

          expect( game.get_status_for_user(current_user) ).to eq false
        end

        it 'game is a postgame' do
          game = FactoryBot.create(:postgame, callback_wanted: :postgame)
          current_user = game.users.first

          expect( game.get_status_for_user(current_user) ).to eq false
        end
      end
    end



    xcontext 'user can see' do

    end

    context 'cant see but needs to be in the html' do
      it 'correct http status' do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        @current_user = game.users.first
        set_signed_cookies({user_id: @current_user.id})

        get new_game_path

        expect(response).to have_http_status :ok
      end

      it 'keeps track of user so the page knows who the game_channel can find out who the user is on the first ' do
        expect(response.body).to match /data-user-id=\"#{@current_user.id}\"/
      end
      it 'knows who the previous card is ', :r5_wip do
        expect(response.body).to match /data-prev-card-id=\"\"/
      end
    end

    xcontext 'user can see' do
    end



    # xcontext 'renders correct variables to page' do
    #   it "person first lands on new" do
    #     game = FactoryBot.create(:game, :midgame_with_no_moves)
    #     current_user = game.users.order(:id).first
    #     # cookies.signed[:user_id] = current_user.id

    #     expect do
    #       get games_path
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
    #       get games_path
    #     end.to change{Card.count}.by(0)

    #     expect(assigns[:game]).to eq game
    #     expect(assigns[:placeholder_card]).to eq find_card
    #     expect(assigns[:prev_card]).to eq find_card.parent_card
    #     expect(assigns[:current_user]).to eq current_user
    #     expect(response).to have_http_status(:success)
    #   end
    # end
  end

  # xdescribe "GET show", working: true do

  #   context 'redirected if' do
  #     it 'user not logged in' do
  #       get :show

  #       expect(response).to redirect_to login_path
  #     end

  #     it 'no current user game' do
  #       game = FactoryBot.create(:game, :postgame)
  #       user = FactoryBot.create(:user)
  #       cookies.signed[:user_id] = user.id

  #       get :show

  #       expect(response).to redirect_to choose_game_type_page_path
  #     end

  #     it 'current game.status == pregame' do
  #       game = FactoryBot.create(:game, :pregame, :public_game)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :show
  #       expect(response).to redirect_to choose_game_type_page_path
  #     end

  #     it 'current game.status == midgame' do
  #       game = FactoryBot.create(:game, :midgame)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :show
  #       expect(response).to redirect_to games_path
  #     end
  #   end

  #   it 'has correct variables being displayed on the page', wip: true do
  #     game = FactoryBot.create(:game, :postgame)
  #     current_user = game.users.order(:id).first
  #     cookies.signed[:user_id] = current_user.id

  #     expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

  #     get :show

  #     expect(assigns[:game]).to eq game
  #     expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
  #     expect(assigns[:current_user]).to eq current_user
  #     expect(response).to have_http_status(:success)
  #   end
  # end

  # xdescribe "GET index", working: true do

  #   context 'redirected if' do
  #     it 'user not logged in' do
  #       get :show

  #       expect(response).to redirect_to login_path
  #     end

  #     it 'current game.status == midgame' do
  #       game = FactoryBot.create(:game, :midgame)
  #       current_user = game.users.order(:id).first
  #       cookies.signed[:user_id] = current_user.id

  #       get :show
  #       expect(response).to redirect_to games_path
  #     end
  #   end

  #   it 'has correct variables being displayed on the page', wip: true do
  #     game = FactoryBot.create(:game, :postgame)
  #     current_user = game.users.order(:id).first
  #     cookies.signed[:user_id] = current_user.id
  #     card_to_find_1 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
  #     card_to_find_2 = FactoryBot.create(:description, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
  #     expect_any_instance_of(Game).to receive(:cards_from_finished_game).once.and_call_original

  #     get :index

  #     expect(assigns[:out_of_game_cards]).to eq [ card_to_find_1, card_to_find_2 ]
  #     expect(assigns[:current_user]).to eq current_user
  #     expect(assigns[:arr_of_postgame_card_sets]).to be_an Array
  #     expect(response).to have_http_status(:success)
  #   end
  # end
end
