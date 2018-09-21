require 'rails_helper'

RSpec.describe User, type: :model do
  context 'factories', r5: true do
    it 'is valid' do
      user1 = FactoryBot.build :user

      expect(user1).to be_valid
      expect(user1.name).to be_a String
      expect(user1.provider.in?(['twitter', 'facebook'])).to eq true
      expect(user1.deleted_at).to eq nil
    end

    it 'is valid' do
      user2 = FactoryBot.build :user, :twitter
      expect(user2).to be_valid
      expect(user2).to be_valid
      expect(user2.name).to be_a String
      expect(user2.provider).to eq 'twitter'
      expect(user2.deleted_at).to eq nil
    end

    it 'is valid' do
      user3 = FactoryBot.build :user, :facebook
      expect(user3).to be_valid
      expect(user3).to be_valid
      expect(user3).to be_valid
      expect(user3.name).to be_a String
      expect(user3.provider).to eq 'facebook'
      expect(user3.deleted_at).to eq nil
    end
  end

  context 'in schema', r5: true do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options({null: false}) }
    it { is_expected.to have_db_column(:provider).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:uid).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_index(:deleted_at) }
  end

  context 'associations', r5: true do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to have_many(:games_users).inverse_of(:user) }
    it { is_expected.to have_many(:games).through(:games_users)}
    it { is_expected.to have_many(:starting_cards).through(:games_users)}
    it { is_expected.to have_one(:current_game).through(:games_users).class_name('Game')}
  end



    # string "name", null: false
    # string "provider", null: false
    # string "uid", null: false
    # datetime "deleted_at"
    # datetime "created_at", null: false
    # datetime "updated_at", null: false
    # index ["deleted_at"], name: "index_users_on_deleted_at"
  context 'methods' do
    # before(:all) do
    #   game = FactoryBot.create(:midgame)
    #   @user = game.users.first
    # end
    context '#current_game', :r5 do
      before :all do
        @pregame = FactoryBot.create :game, :pregame

        @pregame_with_gu_update = FactoryBot.create :game, :pregame
        @updated_gu = @pregame_with_gu_update.games_users.first
        @updated_gu.update(users_game_name: 'Yogi')

        @midgame = FactoryBot.create :game, :midgame
        @postgame = FactoryBot.create :game, :postgame
      end

      context 'returns a game instance', r5: true do

        context 'if a user' do
          it "is in the lobby(rendezvous page) and hasn't entered a character name" do
            user = @pregame.users.first
            expect(user.current_game).to eq @pregame
          end

          it 'has entered a character name and is waiting for other users to join game' do
            user = @pregame_with_gu_update.users.first

            expect(user.current_game).to eq @pregame_with_gu_update
          end

          it 'is midgame' do
            user = @midgame.users.first

            expect(user.current_game).to eq @midgame
          end
        end
      end

      context 'returns a empty relation' do
        it 'no game attached' do
          user = @postgame.users.first

          expect(user.current_game).to eq nil
        end
      end
    end

    context '#current_games_user', :r5 do
      before :all do
        @game1 = FactoryBot.create :game, :pregame
        @user1 = @game1.users.first

        @game2 = FactoryBot.create :game, :midgame
        @user2 = @game2.users.first

        @game3 = FactoryBot.create :game, :postgame
        @user3 = @game3.users.first
      end

      context 'returns a games user of the current game if' do
        it 'game status is pregame' do
          expect(@user1.current_games_user).to eq GamesUser.find_by(game_id: @game1.id, user_id: @user1.id)
        end

        it 'game status is midgame' do
          expect(@user2.current_games_user).to eq GamesUser.find_by(game_id: @game2.id, user_id: @user2.id)
        end
      end

      context 'returns a nil user of the current game if' do
        it 'game status is postgame' do
          expect(@user3.current_games_user).to eq nil
        end
      end
    end

    context '#current_starting_card', :r5 do
      before :all do
        @game1 = FactoryBot.create :game, :pregame
        @user1 = @game1.users.first

        @game2 = FactoryBot.create :game, :midgame
        @user2 = @game2.users.first

        @game3 = FactoryBot.create :game, :postgame
        @user3 = @game3.users.first
      end

      context 'returns the starting card the player made up to pass around the circle if' do
        it 'game status is midgame' do
          expect(@user2.current_starting_card).to eq GamesUser.find_by(user_id: @user2.id, game_id: @game2.id).starting_card
        end
      end

      context 'returns a nil user of the current game if' do
        it 'game status is pregame' do
          expect(@user1.current_starting_card).to eq nil
        end

        it 'game status is postgame' do
          expect(@user3.current_starting_card).to eq nil
        end
      end
    end


    context '#current_games_user_name', :r5 do
      before :all do
        @game1 = FactoryBot.create :game, :pregame
        @user1 = @game1.users.first

        @game2 = FactoryBot.create :game, :midgame
        @user2 = @game2.users.first

        @pregame_with_gu_update = FactoryBot.create :game, :pregame
        @updated_gu = @pregame_with_gu_update.games_users.first
        @updated_gu.update(users_game_name: 'Yogi')

        @midgame_with_gu_update = FactoryBot.create :game, :midgame
        @updated_gu = @midgame_with_gu_update.games_users.first
        @updated_gu.update(users_game_name: 'Yogi')



        @game3 = FactoryBot.create :game, :postgame
        @user3 = @game3.users.first
      end

      context 'returns a games user of the current game if' do
        it 'game status is pregame' do
          expect(@updated_gu.user.current_games_user_name).to eq 'Yogi'
        end

        it 'game status is midgame' do
          expect(@updated_gu.user.current_games_user_name).to eq 'Yogi'
        end
      end

      context 'returns a nil user of the current game if' do
        it 'game status without updateis pregame' do
          expect(@user1.current_games_user_name).to eq nil
        end

        it 'game status is postgame' do
          expect(@user3.current_games_user_name).to eq nil
        end
      end
    end

  end
end
