require 'rails_helper'

RSpec.describe GamesUser, type: :model do

  context 'associations', :r5 do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:game).touch(true) }
    it { is_expected.to have_one(:starting_card).class_name('Card') }
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
      @game = FactoryBot.create(:game, :midgame)
      @games_users = @game.games_users
      @games_user1 = @game.games_users[0]
      @games_user2 = @game.games_users[1]
      @games_user3 = @game.games_users[2]
    end

    it '' do
      expect(@games_users.count).to eq 3
    end

    it 'games_user with no cards return empty relation' do
      expect(@games_users.third.cards).to be_blank
      expect(@games_users.third.cards).to be_a ActiveRecord::Relation
    end

    it 'games_user with 1 cards return empty relation' do
      expect(@games_users.first.cards).to eq [ @games_users.first.starting_card ]
    end

    it 'games_user with one card nested inside another card returns 2 cards' do
      expect(@games_users.second.cards).to eq [ @games_users.second.starting_card, @games_users.second.starting_card.child_card ]
    end

  end
end
