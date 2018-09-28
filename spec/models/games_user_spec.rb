require 'rails_helper'

RSpec.describe GamesUser, type: :model do

  context 'factory', :r5 do
    before :all do
      @factory = FactoryBot.create :games_user
    end

    it 'is valid' do
      expect(@factory).to be_valid
    end

    it 'has associations' do
      expect(@factory.user).to be_a User
      expect(@factory.game).to be_a Game
    end

    it 'has a users_game_name' do
      expect(@factory.users_game_name).to be_a String
    end
  end

  context 'associations', :r5 do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:game).touch(true) }
    it { is_expected.to have_one(:starting_card).class_name('Card') }
    # it { is_expected.to have_one(:starting_card).class_name('Card').foreign_key(:idea_catalyst_id) }
  end

  context 'db schema', :r5 do
    it { is_expected.to have_db_column(:user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:game_id).of_type(:integer) }
    it { is_expected.to have_db_column(:users_game_name).of_type(:string) }
    it { is_expected.to have_db_column(:deleted_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:set_complete).of_type(:boolean).with_options(default: false) }
  end

  context '#cards', :r5 do
    before :all do
      @game = FactoryBot.create(:midgame, callback_wanted: :midgame)
      @games_users = @game.games_users
      @games_user1 = @game.games_users[0]
      @games_user2 = @game.games_users[1]
      @games_user3 = @game.games_users[2]
    end

    it 'assuming there are exactly 3 people playing the game' do
      expect(@games_users.count).to eq 3
    end

    it 'games_user with 1 placeholder starting card' do
      expect(@games_user1.cards).to match_array [ @games_user1.starting_card ]
    end

    it 'games_user with 1 cards and 1 placeholder card returns 2 cards' do
      expect(@games_user2.cards).to match_array [ @games_user2.starting_card, @games_user2.starting_card.child_card ]
    end

    it 'games_user with one card nested inside another card returns 2 cards' do
      expect(@games_user3.cards).to match_array [
                                                   @games_user3.starting_card,
                                                   @games_user3.starting_card.child_card,
                                                   @games_user3.starting_card.child_card.child_card
                                                 ]
    end

  end
end
