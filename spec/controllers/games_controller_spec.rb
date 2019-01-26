require 'rails_helper'


# RSpec.configure do |c|
#   c.include CardHelper
# end

# RSpec.describe GamesController, type: :controller do

#   context 'Actions' do
#     describe ":new", :r5 do

#      # 4 statuses possible
#       # user drawing card
#       # user creating description
#       # user passing is now done and
#       # *) is waiting for friends to finish - aka status: finished
#       # *) all other players are already finished - aka gameover
#       context 'successful; A midgame.' do
#         it 'midgame_with_no_moves' do
#           game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
#           user_1, user_2, user_3 = game.users.order(id: :asc)

#           expected_response = { statuses: [ {
#                                               attention_users: [user_1.id],
#                                               user_status: 'working_on_card'
#                                             },
#                                             {
#                                               attention_users: [user_2.id],
#                                               user_status: 'working_on_card'
#                                             },

#                                             {
#                                               attention_users: [user_3.id],
#                                               user_status: 'working_on_card'
#                                             }
#                                 ]
#                               }

#           expect( game.get_status_for_users([user_1, user_2, user_3]) ).to eq expected_response
#         end

#         context 'Round 1' do
#           context 'Move 1 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             # attributes only visible in games#new and not in_game_card_upload_broadcast
#               #  * expected_response[:back_up_starting_description]
#               #  * expected_response[statuses: {form_authenticity_token:} ]
#               #  * expected_response[:current_user_id]
#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id
#               expected_response = { 'current_user_id': @user_1.id,
#                                     'statuses': [
#                                                   {
#                                                     'form_authenticity_token': (be_a String),
#                                                     'attention_users': [@user_1.id],
#                                                     'user_status': 'waiting'
#                                                   }
#                                                 ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id

#               expected_response = {
#                                     'back_up_starting_description': (be_a String),
#                                     'current_user_id': @user_2.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_2.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3'  do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = {
#                                     'back_up_starting_description': (be_a String),
#                                     'current_user_id': @user_3.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
#             end
#           end

#           context 'Move 2 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id': @user_1.id,
#                                       'statuses': [ {
#                                                       'attention_users': [@user_1.id],
#                                                       'form_authenticity_token': (be_a String),
#                                                       'user_status': 'waiting'
#                                                     }
#                                                   ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['previous_card']).to eq nil # actively call out this is not in expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response

#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id
#               expected_response = { 'current_user_id': @user_2.id,
#                                      'statuses': [ {
#                                         'attention_users': [@user_2.id],
#                                         'form_authenticity_token': (be_a String),
#                                         'previous_card': {
#                                                           'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
#                                                           'medium': 'description'
#                                                          },
#                                         'user_status': 'working_on_card'
#                                       }
#                                     ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = {
#                                     'back_up_starting_description': (be_a String),
#                                     'current_user_id': @user_3.id,
#                                     'statuses': [ {
#                                                   'attention_users': [@user_3.id],
#                                                   'form_authenticity_token' => (be_a String),
#                                                   'user_status': 'working_on_card'
#                                                 }
#                                               ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#             end
#           end

#           context 'Move 3 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 3)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end


#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id': @user_1.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_1.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_1.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   },
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id

#               expected_response = { 'current_user_id': @user_2.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_2.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   },
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = { 'current_user_id': @user_3.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end
#         end

#         context 'Round 2' do
#           context 'Move 1 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id': @user_1.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_1.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'user_status': 'waiting'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['statuses'][0]['previous_card']).to eq nil # actively call out this is not in expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id

#               expected_response = { 'current_user_id': @user_2.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_2.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   },
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = { 'current_user_id': @user_3.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end

#           context 'Move 2 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 2)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end


#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id': @user_1.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_1.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'user_status': 'waiting'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['statuses'][0]['previous_card']).to eq nil # actively call out this is not in expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end


#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id
#               expected_response = {
#                                     'current_user_id': @user_2.id,
#                                     'statuses': [ {
#                                        'attention_users': [@user_2.id],
#                                        'form_authenticity_token': (be_a String),
#                                        'previous_card': {
#                                                          'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
#                                                          'medium': 'drawing'
#                                                         },
#                                        'user_status': 'working_on_card'
#                                       }
#                                     ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end


#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = { 'current_user_id': @user_3.id,
#                                     'statuses': [ {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'description_text': Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
#                                                                        'medium': 'description'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end

#           context 'Move 3 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 3)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = {
#                                     'current_user_id': @user_1.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_1.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_1.id, @game).parent_card ),
#                                                                        'medium': 'drawing'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id
#               expected_response = {
#                                     'current_user_id': @user_2.id,
#                                     'statuses': [ {
#                                        'attention_users': [@user_2.id],
#                                        'form_authenticity_token': (be_a String),
#                                        'previous_card': {
#                                                          'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
#                                                          'medium': 'drawing'
#                                                         },
#                                        'user_status': 'working_on_card'
#                                       }
#                                     ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = {
#                                     'current_user_id': @user_3.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
#                                                                        'medium': 'drawing'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end
#         end

#         context 'Round 3' do
#           context 'Move 1 statuses for everyone' do

#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 1)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id' => @user_1.id,
#                                     'statuses' => [
#                                                   {
#                                                     'attention_users' => [@user_1.id],
#                                                     'user_status' => 'finished'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id
#               expected_response = {
#                                     'current_user_id': @user_2.id,
#                                     'statuses': [ {
#                                        'attention_users': [@user_2.id],
#                                        'form_authenticity_token': (be_a String),
#                                        'previous_card': {
#                                                          'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_2.id, @game).parent_card ),
#                                                          'medium': 'drawing'
#                                                         },
#                                        'user_status': 'working_on_card'
#                                       }
#                                     ]
#                                   }
#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = {
#                                     'current_user_id': @user_3.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
#                                                                        'medium': 'drawing'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end

#           context 'Move 2 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id

#               expected_response = { 'current_user_id' => @user_1.id,
#                                     'statuses' => [
#                                                   {
#                                                     'attention_users' => [@user_1.id],
#                                                     'user_status' => 'finished'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id

#               expected_response = { 'current_user_id' => @user_2.id,
#                                     'statuses' => [
#                                                   {
#                                                     'attention_users' => [@user_2.id],
#                                                     'user_status' => 'finished'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end

#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id

#               expected_response = {
#                                     'current_user_id': @user_3.id,
#                                     'statuses': [
#                                                   {
#                                                     'attention_users': [@user_3.id],
#                                                     'form_authenticity_token': (be_a String),
#                                                     'previous_card': {
#                                                                        'drawing_url': get_drawing_url( Card.get_placeholder_card(@user_3.id, @game).parent_card ),
#                                                                        'medium': 'drawing'
#                                                                      },
#                                                     'user_status': 'working_on_card'
#                                                   }
#                                                 ]
#                                   }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to include_json expected_response
#               expect(assigns['game_component_params']['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
#             end
#           end

#           context 'Move 3 statuses for everyone' do
#             before :all do
#               @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 3)
#               @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
#               @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
#             end

#             it 'user_1' do
#               cookies.signed[:user_id] = @user_1.id
#               expected_response = { 'game_over' => { 'redirect_url' => game_path(@game.id) } }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#             end

#             it 'user_2' do
#               cookies.signed[:user_id] = @user_2.id
#               expected_response = { 'game_over' => { 'redirect_url' => game_path(@game.id) } }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#             end


#             it 'user_3' do
#               cookies.signed[:user_id] = @user_3.id
#               expected_response = { 'game_over' => { 'redirect_url' => game_path(@game.id) } }

#               get :new

#               expect(response).to have_http_status :ok
#               expect(JSON.parse(assigns['game_component_params'])).to eq expected_response
#             end
#           end
#         end
#       end

#       context 'unsuccessful; NOT a midgame' do
#         it 'game is a pregame' do
#           game = FactoryBot.create(:pregame, callback_wanted: :pregame)
#           current_user = game.users.first

#           cookies.signed[:user_id] = current_user.id

#           get :new

#           expect(response).to redirect_to(choose_game_type_page_path)
#         end

#         it 'game is a postgame' do
#           game = FactoryBot.create(:postgame, callback_wanted: :postgame)
#           current_user = game.users.first

#           cookies.signed[:user_id] = current_user.id

#           get :new

#           expect(response).to redirect_to( choose_game_type_page_path )
#         end
#       end
#     end


#     xcontext ':index', :clean_as_group do
#       let!(:unassociated_pregame) { FactoryBot.create(:pregame, callback_wanted: :pregame) }
#       let!(:unassociated_midgame) { FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2) }
#       let!(:unassociated_postgame) { FactoryBot.create(:postgame, callback_wanted: :postgame) }


#       context 'returns json string of component params for the user\'s last postgame' do
#         it 'is returns expected re' do
#           # earlier_postgame =  FactoryBot.create(:postgame, callback_wanted: :postgame)
#           # current_user = earlier_postgame.users.first
#           # current_postgame = FactoryBot.create(:postgame, callback_wanted: :postgame, with_existing_users: [current_user])

#           # out_of_game_card_uploads = GamesUser.where(user: current_user).last.cards.map do |card|

#           #   if card.drawing?
#           #     result = card.slice(:medium, :uploader)
#           #     result.merge!( {'drawing_url' => card.get_drawing_url} )
#           #     result
#           #   else
#           #     card.slice(:medium, :description_text, :uploader)
#           #   end
#           # end

#           # expected__postgame_component_params = {

#           #                                         'current_user' => current_user.slice(:id),
#           #                                         'out_of_game_card_uploads' => out_of_game_card_uploads,

#           #                                         # ,'arr_of_postgame_card_set' => arr_of_postgame_card_set,
#           #                                         'all__current_user__game_info' => current_user.game_ids.sort
#           #                                       }


#           cookies.signed[:user_id] = current_user.id

#           get :index

#           expect(response).to have_http_status :ok
#           expect( JSON.parse(assigns[:postgame_component_params]) ).to include_json expected__postgame_component_params
#         end

#         it 'redirects if no postgames', :r5 do
#           cookies.signed[:user_id] = FactoryBot.create(:user).id

#           get :index

#           expect(response).to redirect_to choose_game_type_page_path
#           expect(assigns[:postgame_component_params] ).to eq nil
#         end
#       end
#     end

#     xcontext ':show' do
#       it 'redirects if no postgames'

#       it 'redirects if user not associated with postgame' do
#         cookies.signed[:user_id] = unassociated_postgame.user_ids.first

#         get :index, params: {id: postgame.id}

#         expect(response).to redirect_to choose_game_type_page_path
#       end
#     end
#   end


#   # describe 'AssemblePostgamesComponentParams', :clean_as_group do
#   #   let!(:unassociated_pregame) { FactoryBot.create(:pregame, callback_wanted: :pregame) }
#   #   let!(:unassociated_midgame) { FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2) }
#   #   let!(:unassociated_postgame) { FactoryBot.create(:postgame, callback_wanted: :postgame) }

#   #   context 'returns json string of component params for the user\'s last postgame' do
#   #     it 'is returns expected re', :r5_wip do
#   #       include ActiveStorageUrlConstructor

#   #         earlier_postgame =  FactoryBot.create(:postgame, callback_wanted: :postgame)
#   #         current_user = earlier_postgame.users.first
#   #         current_postgame = FactoryBot.create(:postgame, callback_wanted: :postgame, with_existing_users: [current_user])

#   #         out_of_game_card_uploads = GamesUser.where(user: current_user).last.cards.map do |card|

#   #           if card.drawing?
#   #             result = card.slice(:medium, :uploader)
#   #             result.merge!( {'drawing_url' => card.get_drawing_url} )
#   #             result
#   #           else
#   #             card.slice(:medium, :description_text, :uploader)
#   #           end
#   #         end

#   #         expected__postgame_component_params = {

#   #                                                 'current_user' => current_user.slice(:id),
#   #                                                 'out_of_game_card_uploads' => out_of_game_card_uploads,

#   #                                                 # ,'arr_of_postgame_card_set' => arr_of_postgame_card_set,
#   #                                                 'all__current_user__game_info' => current_user.game_ids.sort
#   #                                               }
#   #       response = GamesController::AssemblePostgamesComponentParams.new(current_user: current_user, game: current_postgame).result_to_json

#   #       expect( JSON.parse(response) ).to include_json expected__postgame_component_params
#   #     end

#   #     xit 'redirects if no postgames', :r5 do
#   #       # expect(response).to redirect_to choose_game_type_page_path
#   #       # expect(assigns[:postgame_component_params] ).to eq nil
#   #     end
#   #   end
#   # end

# end

require File.join(Rails.root, 'app', 'services', 'active_storage_url_creater' )
require File.join(Rails.root, 'app', 'controllers', 'games_controller', 'assemble_games_component_params' )

RSpec.describe GamesController::AssemblePostgamesComponentParams, :r5, :clean_as_group do
  let!(:unassociated_pregame) { FactoryBot.create(:pregame, callback_wanted: :pregame) }
  let!(:unassociated_midgame) { FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2) }
  let!(:unassociated_postgame) { FactoryBot.create(:postgame, callback_wanted: :postgame) }

  # ONLY TESTING arguments being passed from controller to view in
  context 'Get /games arguments passed into the view' do 
    def arr_of_postgame_card_set game
       Card.cards_from_finished_game(game.id) 
    end

    def all_postgames_of__current_user current_user
      current_user.games.postgame.map do |game|
        result = game.slice(:id)
        result.merge!( { 'created_at_strftime' => game.created_at.strftime('%a %b %e, %Y') } )
      end 
    end

    def current_user_info current_user
      current_user.slice(:id, :name)
    end

    it 'returns json string of component params for the user\'s last postgame', :r5 do
      earlier_postgame =  FactoryBot.create(:postgame, callback_wanted: :postgame)
      current_user = earlier_postgame.users.first
      out_of_game_card_upload = FactoryBot.create :drawing, out_of_game_card_upload: true, uploader: current_user
      current_postgame = FactoryBot.create(:postgame, callback_wanted: :postgame, with_existing_users: [current_user])
    
      expected__postgame_component_params = {
                                              'all_postgames_of__current_user' => all_postgames_of__current_user(current_user),
                                              'arr_of_postgame_card_set' => arr_of_postgame_card_set(current_postgame), 
                                              'current_user_info' => current_user_info(current_user)
                                            }
  
      response = GamesController::AssemblePostgamesComponentParams.new(current_user: current_user, game: current_postgame).result_to_json
      
      expect( JSON.parse(response) ).to include_json expected__postgame_component_params
    end
  end
end

