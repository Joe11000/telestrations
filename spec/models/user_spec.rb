require 'rails_helper'

RSpec.describe User, type: :model do
  context 'factory' do
    it 'is valid' do
      user1 = FactoryBot.build :user
      user2 = FactoryBot.build :user, :twitter
      user3 = FactoryBot.build :user, :facebook

      expect(user1).to be_valid
      expect(user2).to be_valid
      expect(user3).to be_valid
    end
  end

  context 'in schema' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options({null: false}) }
    it { is_expected.to have_db_column(:provider).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:uid).of_type(:integer).with_options(null: false) }
    it { is_expected.to have_db_column(:proveder_avatar).of_type(:string).with_options(null: false) }
  end

  xcontext 'model validations' do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to act_as_paranoid }
    it { is_expected.to have_many(:games_users).inverse_of(:user) }
    it { is_expected.to have_many(:games).through(:games_users)}
    it { is_expected.to have_many(:starting_cards).through(:games_users)}
    it { is_expected.to have_one(:current_game).through(:games_users).optional}

  end


  context 'LOOK UP methods' do
    before(:all) do
      @game = FactoryBot.create(:midgame)
      @user = @game.users.first
    end

    it '#current_game' do
      expect(@user.current_game).to eq @game
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

    it '#unassociated_cards', working: true do
      current_user = @game.users.order(:id).first
      card_to_find_1 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
      card_to_find_2 = FactoryBot.create(:description, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)

      expect(current_user.unassociated_cards).to eq [ card_to_find_1, card_to_find_2 ]
    end

  end
end
