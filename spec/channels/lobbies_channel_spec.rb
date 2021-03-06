require 'rails_helper'
# require 'support/lobby_channel_helpers'

RSpec.describe LobbyChannel, type: :channel do
  let(:action_cable) { ActionCable.server }

  context '#subscribe', :r5 do
    context 'if a user is not subscribed to any other streams' do
      before(:all) do
        @game = FactoryBot.create(:pregame, callback_wanted: :pregame)
        @new_user = FactoryBot.create :user
      end


      it 'they are subscribed to the channel' do
        stub_connection( current_user: @new_user )

        expect { subscribe join_code: @game.join_code}.to have_broadcasted_to("lobby_#{@game.join_code}").with { |data|
          expect(data[:partial]).to match(/Users Not Joined \( 4 \)/)
          expect(data[:partial]).to match(/Users Joined \( 0 \)/)
        }

        @game.reload
        expect(@game.user_ids).to include @new_user.id
        expect(subscription).to be_confirmed
        expect(streams).to eq(["lobby_#{@game.join_code}"])
      end
    end

    context 'if a user is subscribed to another stream' do
      context "and that channel's name uses the join code of another pregame", :r5 do
        before(:all) do
          @game_1 = FactoryBot.create(:pregame, callback_wanted: :pregame)
          @user = @game_1.users.first
          @game_2 = FactoryBot.create(:pregame, callback_wanted: :pregame)

          stub_connection( current_user: @user )
          subscribe join_code: @game_1.join_code
        end

        it 'closes the previous channel and opens a channel for the new pregame' do
          expect(subscription).to be_confirmed

          expect( @game_1.reload.user_ids ).to include @user.id
          expect( @game_2.reload.user_ids ).to_not include @user.id

          subscribe( join_code: @game_2.join_code )

          expect(subscription).to be_confirmed
          expect( @game_1.reload.user_ids ).not_to include @user.id
          expect( @game_2.reload.user_ids ).to include @user.id

        end
      end

      context "and that channel's name uses the join code of midgame", :r5_overlook do
        let(:action_cable) { ActionCable.server }

        it 'short circuits does not allow user to subscribe' do
          @game_1 = FactoryBot.create(:pregame, callback_wanted: :pregame)
          @game_1_join_code = @game_1.join_code
          @user = FactoryBot.create :user

          stub_connection( current_user: @user )
          # expect(action_cable).to receive(:broadcast).with("lobby_#{@game_1.join_code}").exactly.once
          subscribe join_code: @game_1.join_code
          perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game})

          @game_1.start_game
          @game_1.reload
          @game_2 = FactoryBot.create(:pregame, callback_wanted: :pregame)

          expect {
            subscribe join_code: @game_2.join_code
          }.not_to have_broadcasted_to("lobby_#{@game_2.join_code}")


          # expect(streams).to eq ["lobby_#{@game_1_join_code}"]
          expect( @game_1.reload.user_ids ).to include @user.id
          expect( @game_2.reload.user_ids ).to_not include @user.id
        end
      end
    end
  end

  context '#join_game', :r5 do
    context 'lobbying players join a game by submitting a games_user_name' do
      before(:all) do
        # 3 players lobbying on game and logged in as user_1
          @game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          @user = @game.users.first
          stub_connection( current_user: @user )
          subscribe join_code: @game.join_code
      end

      it do
        expect { perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game}) }.to have_broadcasted_to("lobby_#{@game.join_code}").with { |data|
          expect(data[:partial]).to match(/Users Not Joined \( #{@game.users.count - 1} \)/)
          expect(data[:partial]).to match(/Users Joined \( 1 \)/)
          expect(data[:partial]).to match(/Kirmit the Yoda/)
        }
      end
    end
  end

  context '#unjoin_game', :r5 do
    context 'if they ARE the only user on the page' do
      before(:each) do
        # 3 players lobbying on game and logged in as user_1
          @game = FactoryBot.create(:pregame, callback_wanted: :pregame, num_of_players: 1)
          @num_of_users = @game.users.count
          @current_user = @game.users.first
          stub_connection( current_user: @current_user )
          subscribe join_code: @game.join_code
        # commit current player to game with games user name
          perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game})
      end


      # don't konw how to test multiple broadcasts were received and their contents.
      it 'should only receive broadcast with info about user with given id on html page should leave the page', :r5_wip do

        expect { perform :unjoin_game, {join_code: @game.join_code} }.to have_broadcasted_to("lobby_#{@game.join_code}").with { |data|

        expect(data).to eq ({ 'user_leaving' => {
                                                  'user_id' => @current_user.id.to_s,
                                                  'url' => choose_game_type_page_path
                                                }
                            })
        }
      end

      it "removes the lobby game from the user's current game" do
        expect{
          perform :unjoin_game, {join_code: @game.join_code}
        }.to change{Game.count}.by(-1)

        expect(@current_user.current_game).to eq nil
      end

      it 'unsubscribed from lobby stream' do
        perform :unjoin_game, {join_code: @game.join_code}

        expect(streams).to eq []
      end
    end

    context 'if they ARE NOT the only user on the page' do
      before(:each) do
        # 3 players lobbying on game and logged in as user_1
          @game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          @num_of_users = @game.users.count
          @current_user = @game.users.first
          stub_connection( current_user: @current_user )
          subscribe join_code: @game.join_code
        # commit current player to game with games user name
          perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game})
      end


      # don't konw how to test multiple broadcasts were received and their contents.
      it 'should receive broadcast about how user with user id on html page should leave the page and updated partial for everybody else' do

        expect { perform :unjoin_game, {join_code: @game.join_code} }.to have_broadcasted_to("lobby_#{@game.join_code}").with { |data|

        expect(data['user_leaving']).to eq ({
                                              'user_id' => @current_user.id.to_s,
                                              'url' => choose_game_type_page_path
                                           })

          expect(data['partial']).to match(/Users Not Joined \( 2 \)/)
          expect(data['partial']).to match(/Users Joined \( 0 \)/)
          expect(data['partial']).not_to match(/Kirmit the Yoda/)
        }
      end

      it "removes the lobby game from the user's current game" do
        perform :unjoin_game, {join_code: @game.join_code}

        expect(@game.reload.users.count).to eq (@num_of_users - 1)
        expect(@current_user.current_game).to eq nil
      end

      it 'unsubscribed from lobby stream' do
        perform :unjoin_game, {join_code: @game.join_code}

        expect(streams).to eq []
      end
    end
  end

  context '#start_game', :r5 do

    context 'game DOES have enough players' do
      before(:each) do
        # 3 players lobbying on game and logged in as user_1
          @game = FactoryBot.create(:pregame, callback_wanted: :pregame)
          @user = @game.users.first
          stub_connection( current_user: @user )
          subscribe join_code: @game.join_code
          @gu1, @gu2, @gu3 = @game.games_users
          # commit 2 users to the game with games user names
          @gu1.update(users_game_name: Faker::Name.first_name)
          @gu2.update(users_game_name: Faker::Name.first_name)
      end

      it 'removes games_user association for any player that did not submit a users_game_name' do
        perform :start_game, {join_code: @game.join_code}

        @game.reload
        expect(@game.user_ids).to match_array [@gu1.user_id, @gu2.user_id]
        expect(@game.midgame?).to eq true
        expect(JSON.parse(@game.passing_order)).to match_array([@gu1.user_id, @gu2.user_id])
      end

      it 'sends redirect url to all users to start the game via the lobby channel (where expected players will be redirected to the lobby choose game path if they were just removed from the game)' do
        expect { perform :start_game, {join_code: @game.join_code} }.to have_broadcasted_to("lobby_#{@game.join_code}").with({start_game_signal: new_game_path})
      end
    end

    context 'game DOES NOT enough players', :r5 do
      context 'no players have entered a users_game_name' do
        context 'and has 1 player on page' do
          it 'changes nothing and doesnt broadcast' do
            # 3 players lobbying on game and logged in as user_1
            @game = FactoryBot.create(:pregame, callback_wanted: :pregame, num_of_players: 1)
            @user1 = @game.users[0]
            stub_connection( current_user: @user1 )
            subscribe join_code: @game.join_code
            @gu1 = @game.games_users[0]
            # commit 2 users to the game with games user names

            expect(ActionCable.server).not_to receive(:broadcast)

            perform :start_game, join_code: @game.join_code
            @game.reload
            expect(@game.user_ids).to eq [@user1.id]
            expect(@game.pregame?).to eq true
            expect(@game.passing_order).to eq ''
          end
        end

        context 'and has 2 players on page' do
          it 'changes nothing and doesnt broadcast' do
            # 3 players lobbying on game and logged in as user_1
            @game = FactoryBot.create(:pregame, callback_wanted: :pregame, num_of_players: 2)
            @user1 = @game.users[0]
            @user2 = @game.users[1]
            stub_connection( current_user: @user1 )
            subscribe join_code: @game.join_code
            @gu1 = @game.games_users[0]
            @gu2 = @game.games_users[1]
            # commit 2 users to the game with games user names

            expect(ActionCable.server).not_to receive(:broadcast)

            perform :start_game, join_code: @game.join_code
            @game.reload
            expect(@game.user_ids).to eq [@user1.id, @user2.id]
            expect(@game.pregame?).to eq true
            expect(@game.passing_order).to eq ''
          end
        end
      end

      context 'only 1 player entered a users_game_name' do
        context 'and has 1 player on page' do
          it 'changes nothing and doesnt broadcast' do
            # 3 players lobbying on game and logged in as user_1
            @game = FactoryBot.create(:pregame, callback_wanted: :pregame, num_of_players: 1)
            @user1 = @game.users[0]
            stub_connection( current_user: @user1 )
            subscribe join_code: @game.join_code
            @gu1 = @game.games_users[0]
            @gu1.update(users_game_name: Faker::Name.first_name)

            # commit 2 users to the game with games user names

            expect(ActionCable.server).not_to receive(:broadcast)

            perform :start_game, join_code: @game.join_code
            @game.reload
            expect(@game.user_ids).to eq [@user1.id]
            expect(@game.pregame?).to eq true
            expect(@game.passing_order).to eq ''
          end
        end

        context 'and has 2 players on page' do
          it 'changes nothing and doesnt broadcast' do
            # 3 players lobbying on game and logged in as user_1
            @game = FactoryBot.create(:pregame, callback_wanted: :pregame, num_of_players: 2)
            @user1 = @game.users[0]
            @user2 = @game.users[1]
            stub_connection( current_user: @user1 )
            subscribe join_code: @game.join_code
            @gu1 = @game.games_users[0]
            @gu2 = @game.games_users[1]
            @gu1.update(users_game_name: Faker::Name.first_name)

            # commit 2 users to the game with games user names

            expect(ActionCable.server).not_to receive(:broadcast)

            perform :start_game, join_code: @game.join_code
            @game.reload
            expect(@game.user_ids).to eq [@user1.id, @user2.id]
            expect(@game.pregame?).to eq true
            expect(@game.passing_order).to eq ''
          end
        end
      end
    end
  end
end



# RSpec.describe LobbyChannel do
#   subject(:channel) { described_class.new(connection, {}) }

#   let(:current_profile) { double(id: "1", name: "Bob") }

#   # Connection is `identified_by :current_profile`
#   let(:connection) { TestConnection.new(current_profile: current_profile) }

#   let(:action_cable) { ActionCable.server }

#   # ActionCable dispatches actions by the `action` attribute.
#   # In this test we assume the payload was successfully parsed (it could be a JSON payload, for example).
#   let(:data) do
#     {
#       "action" => "test_action",
#       "times_to_say_hello" => 3
#     }
#   end

#   it "broadcasts 'Hello, Bob!' 3 times"  do
#
#     # expect(action_cable).to receive(:broadcast).with("1", "Hello, Bob!").exactly(3).times

#     channel.perform_action(data)
#   end






      # let(:connection) { TestConnection.new(user_id: current_profile) }

         # expect { connect "/cable" }.to have_rejected_connection
        # connect "/cable", cookies: { user_id:  @new_user.id }
