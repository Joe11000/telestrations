require 'rails_helper'
# require 'support/rendezvous_channel_helpers'

RSpec.describe RendezvousChannel, type: :channel do
  before(:all) do
    Game.delete_all
    User.delete_all
    GamesUser.delete_all
    Card.delete_all
  end

  let(:action_cable) { ActionCable.server }

  context '#subscribe', :r5 do
    context 'if a user is not subscribed to any other streams' do
      before(:all) do
        @game = FactoryBot.create :game, :pregame
        @new_user = FactoryBot.create :user
      end


      it 'they are subscribed to the channel' do
        stub_connection( current_user: @new_user )

        expect { subscribe join_code: @game.join_code}.to have_broadcasted_to("rendezvous_#{@game.join_code}").with { |data|
          expect(data[:partial]).to match(/Users Not Joined \( #{@game.users.count} \)/)
          expect(data[:partial]).to match(/Users Joined \( 0 \)/)
        }

        @game.reload
        expect(@game.user_ids).to include @new_user.id
        expect(subscription).to be_confirmed
        expect(streams).to eq(["rendezvous_#{@game.join_code}"])
      end
    end

    context 'if a user is subscribed to another stream' do
      context "and that channel's name uses the join code of another pregame", :r5 do
        before(:all) do
          @game_1 = FactoryBot.create :game, :pregame
          @user = @game_1.users.first
          @game_2 = FactoryBot.create :game, :pregame

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
          @game_1 = FactoryBot.create :game, :pregame
          @game_1_join_code = @game_1.join_code
          @user = FactoryBot.create :user

          stub_connection( current_user: @user )
          # expect(action_cable).to receive(:broadcast).with("rendezvous_#{@game_1.join_code}").exactly.once
          subscribe join_code: @game_1.join_code
          perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game})

          @game_1.start_game
          @game_1.reload
          @game_2 = FactoryBot.create :game, :pregame

          expect {
            subscribe join_code: @game_2.join_code
          }.not_to have_broadcasted_to("rendezvous_#{@game_2.join_code}")


          # expect(streams).to eq ["rendezvous_#{@game_1_join_code}"]
          expect( @game_1.reload.user_ids ).to include @user.id
          expect( @game_2.reload.user_ids ).to_not include @user.id
        end
      end
    end
  end

  context '#join_game' do
    context 'rendezvousing players join a game by submitting a games_user_name', :r5 do
      before(:all) do
        # 3 players rendezvousing on game and logged in as user_1
          @game = FactoryBot.create(:game, :pregame)
          @user = @game.users.first
          stub_connection( current_user: @user )
          subscribe join_code: @game.join_code
      end

      it do
        expect { perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game}) }.to have_broadcasted_to("rendezvous_#{@game.join_code}").with { |data|
          expect(data[:partial]).to match(/Users Not Joined \( #{@game.users.count - 1} \)/)
          expect(data[:partial]).to match(/Users Joined \( 1 \)/)
          expect(data[:partial]).to match(/Kirmit the Yoda/)
        }
      end
    end

  end

  context '#unjoin_game' do
    context 'remove joined player after they commited to the game' do
      before(:all) do
        # 3 players rendezvousing on game and logged in as user_1
          @game = FactoryBot.create(:game, :pregame)
          @num_of_users = @game.users.count
          @user = @game.users.first
          stub_connection( current_user: @user )
          subscribe join_code: @game.join_code
        # commit current player to game with games user name
          perform :join_game, ({users_game_name: 'Kirmit the Yoda', action: :join_game})
      end

      it do
        expect { perform :unjoin_game, {join_code: @game.join_code} }.to have_broadcasted_to("rendezvous_#{@game.join_code}").with { |data|
          expect(data[:partial]).to match(/Users Not Joined \( #{@game.users.count} \)/)
          expect(data[:partial]).to match(/Users Joined \( 0 \)/)
          expect(data[:partial]).not_to match(/Kirmit the Yoda/)
        }

        expect(@game.reload.users.count).to eq (@num_of_users - 1)
        expect(@user.current_game).to eq nil
      end
    end
  end

  context '#start_game', :r5_wip do
    before(:all) do
      # 3 players rendezvousing on game and logged in as user_1
        @game = FactoryBot.create(:game, :pregame)
        @user = @game.users.first
        stub_connection( current_user: @user )
        subscribe join_code: @game.join_code
        @gu1, @gu2, @gu3 = @game.games_users
        # commit 2 users to the game with games user names
        @gu1.update(users_game_name: Faker::Name.first_name)
        @gu2.update(users_game_name: Faker::Name.first_name)
    end

    it do
      expect { perform :start_game, {join_code: @game.join_code} }.to have_broadcasted_to("rendezvous_#{@game.join_code}").with({start_game_signal: game_page_url})
      @game.reload
      expect(@game.user_ids).to eq [@gu1.user_id, @gu2.user_id]
      expect(@game.midgame?).to eq true
      expect(JSON.parse(@game.passing_order)).to match_array([@gu1.user_id, @gu2.user_id])
    end
  end
end



# RSpec.describe RendezvousChannel do
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
