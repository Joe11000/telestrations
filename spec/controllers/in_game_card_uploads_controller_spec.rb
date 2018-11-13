require 'rails_helper'

RSpec.configure do |c|
  c.include CardHelper
end

RSpec.describe InGameCardUploadsController, type: :controller do
  describe "GET #new", :r5 do

    # 3rd time testing this because it should be the same results from game#get_status_for_users and not the same as games_controller#new.
    # The in_game_card_upload_broadcast broadcast shouldn't have attributes only visible in games#new
      #  * expected_response[:back_up_starting_description]
      #  * expected_response[statuses: {form_authenticity_token:} ]
      #  * expected_response[:current_user_id]
    context 'successful; A midgame.' do
      context 'Round 1', :r5 do
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
        context 'Move 1 statuses for those involved in the transaction', :r5 do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 1, move: 2, num_of_players: 2)
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user

            @file_name = 'Ace_of_Diamonds.jpg'
            @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")
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

        context 'Move 2 statuses for players involved in transaction', :r5_wip do
          before :all do
            @game = FactoryBot.create(:midgame, callback_wanted: :midgame, round: 2, move: 1, num_of_players: 2 )
            @gu_1, @gu_2 = @game.games_users.order(id: :asc)
            @user_1, @user_2 = @gu_1.user, @gu_2.user

            @file_name = 'Ace_of_Diamonds.jpg'
            @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")
          end

          it 'user_2 and user_1' do
            cookies.signed[:user_id] = @user_2.id

            expected_response = { 'game_over' => { 'redirect_url' => game_path(@game.id) } }

            expect(ActionCable.server).to receive(:broadcast).with( "game_#{@game.id}", expected_response.to_json )

            post :create, params: { card: {description_text: @expected_description_text }, format: :js}

            expect(response).to have_http_status :ok
            expect(JSON.parse(assigns['broadcast_statuses'])).to eq expected_response

            expect(@game.cards.count).to eq 4
          end
        end
      end
    end

    context 'unsuccessful; NOT a midgame' do
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


          @file_name = 'Ace_of_Diamonds.jpg'
          @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")
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

          @file_name = 'Ace_of_Diamonds.jpg'
          @drawn_image = Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec' ,'support', 'images', @file_name ), "image/jpg")
          post :create, params: { card: {drawing: @drawn_image }, format: :js}

          expect(response).to redirect_to(choose_game_type_page_path)
        end
      end
    end
  end
end
