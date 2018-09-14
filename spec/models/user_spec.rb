require 'rails_helper'

RSpec.describe User, type: :model do
  context 'factory', r5: true do
    it 'is valid' do
      user1 = FactoryBot.build :user
      user2 = FactoryBot.build :user, :twitter
      user3 = FactoryBot.build :user, :facebook

      expect(user1).to be_valid
      expect(user2).to be_valid
      expect(user3).to be_valid
    end
  end

  context 'in schema', r5: true do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options({null: false}) }
    it { is_expected.to have_db_column(:provider).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:uid).of_type(:string).with_options(null: false) }
  end

  context 'model validations', r5: true do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to have_many(:games_users).inverse_of(:user) }
    it { is_expected.to have_many(:games).through(:games_users)}
    it { is_expected.to have_many(:starting_cards).through(:games_users)}
    it { is_expected.to have_one(:current_game).through(:games_users).class_name('Game')}
  end


  context 'methods' do
    # before(:all) do
    #   @game = FactoryBot.create(:midgame)
    #   @user = @game.users.first
    # end
    context '#current_game' do

      context 'returns a game instance' do
        context 'if a user' do
          it "is in the lobby(rendezvous page) and hasn't entered a character name" do
            @game = FactoryBot.create :game, :pregame
            @user.current_game
            expect(@user.current_game).to eq @game
            expect(@user.current_game.postgame?).to eq false
          end
          it 'has entered a character name and is waiting for other users to join game'
          it 'is midgame'
        end
      end

      context 'returns a empty relation' do
         it 'no game attached'
       end
    end

    it '#gamesuser_in_current_game' do
      expect(@user.gamesuser_in_current_game).to eq GamesUser.find_by(game_id: @game.id, user_id: @user.id)
    end

    it '#starting_card_in_current_game' do
      expect(@user.starting_card_in_current_game).to eq @user.gamesuser_in_current_game.starting_card
    end

    it '#users_game_name' do
      expect(@user.users_game_name).to eq @user.gamesuser_in_current_game.users_game_name
    end


  end
end
