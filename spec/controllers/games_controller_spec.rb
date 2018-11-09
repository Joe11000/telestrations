require 'rails_helper'

RSpec.configure do |c|
  c.include CardHelper
end

RSpec.describe GamesController, type: :controller do
  describe "GET #new", :r5 do


   # 4 statuses possible
    # user drawing card
    # user creating description
    # user passing is now done and
    # *) is waiting for friends to finish - aka status: finished
    # *) all other players are already finished - aka gameover
    context 'successful; A midgame.' do
      it 'midgame_with_no_moves' do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        user_1, user_2, user_3 = game.users.order(id: :asc)

        expected_response = { statuses: [ {
                                            attention_users: [user_1.id],
                                            user_status: 'working_on_card'
                                          },
                                          {
                                            attention_users: [user_2.id],
                                            user_status: 'working_on_card'
                                          },

                                          {
                                            attention_users: [user_3.id],
                                            user_status: 'working_on_card'
                                          }
                              ]
                            }

        expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
      end

      context 'Round 1' do
        context 'Move 1 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          # attributes only visible in games#new and not in_game_card_upload_broadcast
            #  * expected_response[:back_up_starting_description]
            #  * expected_response[statuses: {form_authenticity_token:} ]
            #  * expected_response[:current_user_id]
          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id
            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [
                                                {
                                                  'form_authenticity_token': (be_a String),
                                                  'attention_users': [@user_1.id],
                                                  'user_status': 'waiting'
                                                }
                                              ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = {
                                  'back_up_starting_description': (be_a String),
                                  'current_user_id': @user_2.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_2.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_3'  do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'back_up_starting_description': (be_a String),
                                  'current_user_id': @user_3.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
          end
        end

        context 'Move 2 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                    'statuses': [ {
                                                    'attention_users': [@user_1.id],
                                                    'form_authenticity_token': (be_a String),
                                                    'user_status': 'waiting'
                                                  }
                                                ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = { 'current_user_id': @user_2.id,
                                   'statuses': [ {
                                      'attention_users': [@user_2.id],
                                      'form_authenticity_token': (be_a String),
                                      'previous_card': {
                                                        'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
                                                        'medium': 'description'
                                                       },
                                      'user_status': 'working_on_card'
                                    }
                                  ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'back_up_starting_description': (be_a String),
                                  'current_user_id': @user_3.id,
                                  'statuses': [ {
                                                'attention_users': [@user_3.id],
                                                'form_authenticity_token' => (be_a String),
                                                'user_status': 'working_on_card'
                                              }
                                            ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end

        context 'Move 3 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 3)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end


          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_1.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_1.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                },
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = { 'current_user_id': @user_2.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_2.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                },
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = { 'current_user_id': @user_3.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end
      end

      context 'Round 2' do
        context 'Move 1 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_1.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'user_status': 'waiting'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
            expect(assigns['game_component_params']['statuses'][0]['previous_card']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = { 'current_user_id': @user_2.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_2.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                },
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = { 'current_user_id': @user_3.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end

        context 'Move 2 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end


          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_1.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'user_status': 'waiting'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
            expect(assigns['game_component_params']['statuses'][0]['previous_card']).to eq nil # actively call out this is not in expected_response
          end


          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = {
                                  'current_user_id': @user_2.id,
                                  'statuses': [ {
                                     'attention_users': [@user_2.id],
                                     'form_authenticity_token': (be_a String),
                                     'previous_card': {
                                                       'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
                                                       'medium': 'drawing'
                                                      },
                                     'user_status': 'working_on_card'
                                    }
                                  ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end


          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = { 'current_user_id': @user_3.id,
                                  'statuses': [ {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
                                                                     'medium': 'description'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end

        context 'Move 3 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 3)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = {
                                  'current_user_id': @user_1.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_1.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_1.id, @game).parent_card ),
                                                                     'medium': 'drawing'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = {
                                  'current_user_id': @user_2.id,
                                  'statuses': [ {
                                     'attention_users': [@user_2.id],
                                     'form_authenticity_token': (be_a String),
                                     'previous_card': {
                                                       'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
                                                       'medium': 'drawing'
                                                      },
                                     'user_status': 'working_on_card'
                                    }
                                  ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'current_user_id': @user_3.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
                                                                     'medium': 'drawing'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end
      end

      context 'Round 3' do
        context 'Move 1 statuses for everyone' do

          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_1.id],
                                                  'user_status': 'finished'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = {
                                  'current_user_id': @user_2.id,
                                  'statuses': [ {
                                     'attention_users': [@user_2.id],
                                     'form_authenticity_token': (be_a String),
                                     'previous_card': {
                                                       'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
                                                       'medium': 'drawing'
                                                      },
                                     'user_status': 'working_on_card'
                                    }
                                  ]
                                }
            get :new

            expect(response).to have_http_status :ok
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'current_user_id': @user_3.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
                                                                     'medium': 'drawing'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end

        context 'Move 2 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = { 'current_user_id': @user_1.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_1.id],
                                                  'user_status': 'finished'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = { 'current_user_id': @user_2.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_2.id],
                                                  'user_status': 'finished'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
            expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
          end

          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'current_user_id': @user_3.id,
                                  'statuses': [
                                                {
                                                  'attention_users': [@user_3.id],
                                                  'form_authenticity_token': (be_a String),
                                                  'previous_card': {
                                                                     'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
                                                                     'medium': 'drawing'
                                                                   },
                                                  'user_status': 'working_on_card'
                                                }
                                              ]
                                }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end

        context 'Move 3 statuses for everyone' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 3)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
          end

          it 'user_1' do
            cookies.signed[:user_id] = @user_1.id
            expected_response = { 'game_over': { 'redirect_url': game_path(@game.id) } }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end

          it 'user_2' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = { 'game_over': { 'redirect_url': game_path(@game.id) } }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end


          it 'user_3' do
            cookies.signed[:user_id] = @user_3.id
            expected_response = { 'game_over': { 'redirect_url': game_path(@game.id) } }

            get :new

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
          end
        end
      end

      xit 'Move 3 statuses for everyone' do
        game = FactoryBot.create(:postgame, callback_wanted: :postgame)
        gu_1, gu_2, gu_3 = game.games_users.order(id: :asc)
        user_1, user_2, user_3 = gu_1.user, gu_2.user, gu_3.user

        expected_response = { game_over: { redirect_url: game_path(game.id) } }

        expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
        expect( game.get_status_for_users([user_1, user_2]) ).to eq expected_response
        expect( game.get_status_for_users([user_1]) ).to eq expected_response
      end
    end

    context 'unsuccessful; NOT a midgame' do
      it 'game is a pregame' do
        game = FactoryBot.create(:pregame, callback_wanted: :pregame)
        current_user = game.users.first

        cookies.signed[:user_id] = current_user.id

        get :new

        expect(response).to redirect_to(choose_game_type_page_path)
      end

      it 'game is a postgame' do
        game = FactoryBot.create(:postgame, callback_wanted: :postgame)
        current_user = game.users.first

        cookies.signed[:user_id] = current_user.id

        get :new

        expect(response).to redirect_to( choose_game_type_page_path )
      end
    end
  end

  xdescribe "GET #show" do
    it "returns http success" do
      get :show
      expect(response).to have_http_status(:success)
    end
  end

  xdescribe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

end
