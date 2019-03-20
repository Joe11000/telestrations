require 'rails_helper'
require File.join(Rails.root, 'app', 'services', 'active_storage_url_creater')

RSpec.describe InGameCardUploadsController, type: :controller do
  # include ActiveStorageUrlCreater

  describe "GET #new", :r5 do

    # 3rd time testing this because it should be the same results from game#get_status_for_users and not the same as games_controller#new.
    # The in_game_card_upload_broadcast broadcast shouldn't have attributes only visible in games#new
      #  * expected_response[:back_up_starting_description]
      #  * expected_response[statuses: {form_authenticity_token:} ]
      #  * expected_response[:current_user_id]
    context 'Successful; In a 2-Player midgame.' do
      context 'Round 1' do
        context 'Move 1 statuses for people involved' do
          before :all do
            @game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves, num_of_players: 2)
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)

          end

          it 'user_1 and user_2' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = {
                                  'statuses' => [
                                                {
                                                  'attention_users' => [@user_1.id],
                                                  'user_status' => 'waiting'
                                                },
                                               {
                                                  'attention_users' => [@user_2.id],
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }




            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            expect do
              post :create, params: { card: {description_text: @expected_description_text }, format: :js}
            end.to change{ @game.cards.length }.from(2).to(3)

            expect(response).to have_http_status :ok
          end
        end

        context 'Move 2 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1, num_of_players: 2)
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)
          end

          it 'user_2 and user_1' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = {
                                   'statuses' => [ {
                                      'attention_users' => [@user_2.id],
                                      'previous_card' => {
                                                        'description_text' => @gu_1.starting_card.description_text,
                                                        'medium' => 'description'
                                                       },
                                      'user_status' => 'working_on_card'
                                    },
                                    {
                                      'attention_users' => [@user_1.id],
                                      'previous_card' => {
                                                         'description_text' => @expected_description_text,
                                                         'medium' => 'description'
                                                       },
                                      'user_status' => 'working_on_card'
                                    }
                                  ]
                                }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            expect do
              post :create, params: { card: {description_text: @expected_description_text }, format: :js}
            end.to change{ @game.cards.length }.from(3).to(4)

            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
            expect(response).to have_http_status :ok
          end
        end
      end

      context 'Round 2' do
        context 'Move 1 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2, num_of_players: 2)
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user

            @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")
          end

          it 'user_1 and user_2' do
            cookies.signed[:user_id] = @user_1.id


            expected_response = {
                                  'statuses' => [
                                                  {
                                                    'attention_users' => [@user_1.id],
                                                    'user_status' => 'finished'
                                                  },
                                                  {
                                                    'attention_users' => [@user_2.id],
                                                    'previous_card' => {
                                                                       'description_text' => Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
                                                                       'medium' => 'description'
                                                                     },
                                                    'user_status' => 'working_on_card'
                                                  }
                                                ]
                                }

            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once
            expect(@game.cards.length).to eq 4

            post :create, params: { card: { drawing: @drawn_image }, format: :js}

            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
            expect(@game.cards.length).to eq 4
            expect(response).to have_http_status :ok
          end
        end

        context 'Move 2 statuses for players involved in transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1, num_of_players: 2 )
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user

            @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")
          end

          it 'user_2 and user_1' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = { 'game_over' => { 'redirect_url' => games_path } }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", expected_response.to_json ).once

            post :create, params: { card: { drawing: @drawn_image }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response

            expect(@game.cards.count).to eq 4
          end
        end
      end
    end

    context 'Successful; In a 3-Player midgame.' do
      context 'Round 1' do
        context 'Move 1 statuses for people involved' do
          before :all do
            @game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)

          end

          it 'user_1 and user_2' do
            cookies.signed[:user_id] = @user_1.id
            expected_response = {
                                  'statuses' => [
                                                {
                                                  'attention_users' => [@user_1.id],
                                                  'user_status' => 'waiting'
                                                },
                                               {
                                                  'attention_users' => [@user_2.id],
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }




            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(response).to have_http_status :ok
          end
        end

        context 'Move 2 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)
          end

          it 'user_2 and user_3' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = {
                                   'statuses' => [ {
                                      'attention_users' => [@user_2.id],
                                      'previous_card' => {
                                                        'description_text' => @gu_1.starting_card.description_text,
                                                        'medium' => 'description'
                                                       },
                                      'user_status' => 'working_on_card'
                                    },
                                    {
                                      'attention_users' => [@user_3.id],
                                      'user_status' => 'working_on_card'
                                    }
                                  ]
                                }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
            expect(response).to have_http_status :ok
          end
        end

        context 'Move 3 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)

          end

          it 'user_1 and user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'statuses' => [ {
                                                  'attention_users' => [@user_3.id],
                                                  'previous_card' => {
                                                                     'description_text' => @gu_2.starting_card.description_text,
                                                                     'medium' => 'description'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                },
                                                {
                                                  'attention_users' => [@user_1.id],
                                                  'previous_card' => {
                                                                     'description_text' => @expected_description_text,
                                                                     'medium' => 'description'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
            expect(response).to have_http_status :ok
          end
        end
      end

      context 'Round 2' do
        context 'Move 1 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 3)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user

            @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")
          end

          it 'user_1 and user_2' do
            cookies.signed[:user_id] = @user_1.id


            expected_response = {
                                  'statuses' => [ {
                                                  'attention_users' => [@user_1.id],
                                                  'user_status' => 'waiting'
                                                },
                                                {
                                                  'attention_users' => [@user_2.id],
                                                  'previous_card' => {
                                                                     'description_text' => Card.get_placeholder_card(@user_2.id, @game).parent_card.description_text,
                                                                     'medium' => 'description'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }

            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {drawing: @drawn_image }, format: :js}

            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response

            expect(response).to have_http_status :ok
          end
        end

        context 'Move 2 statuses for players involved in transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user

            @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")
          end

          it 'user_2 and user_3' do
            cookies.signed[:user_id] = @user_2.id
            expected_response = {
                                  'statuses' => [ {
                                     'attention_users' => [@user_2.id],
                                     'previous_card' => {
                                                       'drawing_url' => @gu_3.starting_card.child_card.get_drawing_url, # can't know the image url before it is created,
                                                       'medium' => 'drawing'
                                                      },
                                     'user_status' => 'working_on_card'
                                    },
                                    {
                                      'attention_users' => [@user_3.id],
                                      'previous_card' => {
                                                        'description_text' => Card.get_placeholder_card(@user_3.id, @game).parent_card.description_text,
                                                        'medium' => 'description'
                                                       },
                                      'user_status' => 'working_on_card'
                                    }
                                  ]
                                }

            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {drawing: @drawn_image }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
          end
        end

        context 'Move 3 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user

            @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")
          end

          it 'user_1 and user_3' do
            cookies.signed[:user_id] = @user_3.id

            expected_response = {
                                  'statuses' => [
                                                {
                                                  'attention_users' => [@user_3.id],
                                                  'previous_card' => {
                                                                     'drawing_url' => @gu_1.cards[1].get_drawing_url,
                                                                     'medium' => 'drawing'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                },
                                                {
                                                  'attention_users' => [@user_1.id],
                                                  'previous_card' => {
                                                                     'drawing_url' => (be_a String),
                                                                     'medium' => 'drawing'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }

            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {drawing: @drawn_image }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to include_json expected_response

            JSON.parse(assigns['broadcast_statuses'])['statuses'].each do |status|
              expect(status['back_up_starting_description']).to eq nil # actively call out this is not in expected_response
              expect(status['form_authenticity_token']).to eq nil # actively call out this is not in expected_response
            end
          end
        end
      end

      context 'Round 3' do
        context 'Move 1 statuses for those involved in the transaction' do

          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 3)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)
          end


          it 'user_1 and user_2' do
            cookies.signed[:user_id] = @user_1.id

            expected_response = {
                                  'statuses' => [
                                                  {
                                                    'attention_users' => [@user_1.id],
                                                    'user_status' => 'finished'
                                                  },
                                                  {
                                                   'attention_users' => [@user_2.id],
                                                   'previous_card' => {
                                                                     'drawing_url' => Card.get_placeholder_card(@user_2.id, @game).parent_card.get_drawing_url,
                                                                     'medium' => 'drawing'
                                                                    },
                                                   'user_status' => 'working_on_card'
                                                  }
                                                ]
                                }
            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
          end
        end

        context 'Move 2 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 1)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)
          end

          it 'user_2 and user_3' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = {
                                  'statuses' => [
                                                {
                                                  'attention_users' => [@user_2.id],
                                                  'user_status' => 'finished'
                                                },
                                                {
                                                  'attention_users' => [@user_3.id],
                                                  'previous_card' => {
                                                                     'drawing_url' => Card.get_placeholder_card(@user_3.id, @game).parent_card.get_drawing_url,
                                                                     'medium' => 'drawing'
                                                                   },
                                                  'user_status' => 'working_on_card'
                                                }
                                              ]
                                }

            # THIS IS LIKE THIS BECAUSE THE JSON GETS MOVED AROUND WHEN IT GETS TRANSFORMED INTO JSON IN THE CONTROLLER.
            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", kind_of(String) ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
          end
        end

        context 'Move 3 statuses for those involved in the transaction' do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 3, move: 2)
            @gu_1, @gu_2, @gu_3 = @game.games_users.order(id: :asc)
            @user_1, @user_2, @user_3 = @gu_1.user, @gu_2.user, @gu_3.user
            @expected_description_text = TokenPhrase.generate(' ', numbers: false)
          end

          it 'everyone' do
            cookies.signed[:user_id] = @user_3.id
            expected_response = { 'game_over' => { 'redirect_url' => games_path } }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", expected_response.to_json ).once

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response
          end
        end
      end
    end

    context 'Unsuccessful; NOT a midgame' do
      context 'game is a pregame' do
        it 'and uploading a description' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          current_user = game.users.first

          cookies.signed[:user_id] = current_user.id

          expect(ActionCable.server).not_to receive(:broadcast).with(any_args)

          post :create, params: { card: {description_text: @expected_description_text }, format: :js}

          expect(response).to redirect_to(choose_game_type_page_path)
        end

        it 'and uploading a drawing' do
          game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          current_user = game.users.first

          cookies.signed[:user_id] = current_user.id

          expect(ActionCable.server).not_to receive(:broadcast).with(any_args)

          @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")

          post :create, params: { card: {drawing: @drawn_image }, format: :js}

          expect(response).to redirect_to(choose_game_type_page_path)
        end
      end


      context 'game is a postgame' do
        it 'and uploading a description' do
          game = FactoryBot.create(:postgame, callback_wanted: :postgame)
          current_user = game.users.first

          cookies.signed[:user_id] = current_user.id

          expect(ActionCable.server).not_to receive(:broadcast).with(any_args)

          post :create, params: { card: {description_text: @expected_description_text }, format: :js}

          expect(response).to redirect_to(choose_game_type_page_path)
        end

        it 'and uploading a drawing' do
          game = FactoryBot.create(:postgame, callback_wanted: :postgame)
          current_user = game.users.first

          cookies.signed[:user_id] = current_user.id

          expect(ActionCable.server).not_to receive(:broadcast).with(any_args)

          @drawn_image = fixture_file_upload('images/Ace_of_Diamonds.jpg', "image/jpg")

          post :create, params: { card: {drawing: @drawn_image }, format: :js}

          expect(response).to redirect_to(choose_game_type_page_path)
        end
      end
    end
  end
end
