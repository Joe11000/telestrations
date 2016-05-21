require 'rails_helper'

RSpec.describe User, type: :model do

  xcontext 'model validations' do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to have_many(:games_users).inverse_of(:user) }
    it { is_expected.to have_many(:games).through(:games_users)}
    it { is_expected.to have_many(:starting_cards).through(:games_users)}

    # paperclip
    it { is_expected.to have_attached_file(:provider_avatar_override) }
    it { is_expected.to validate_attachment_size(:provider_avatar_override).
                  less_than(5.megabytes) }
    it { is_expected.to validate_attachment_content_type(:provider_avatar_override).
                  allowing("image/jpeg", "image/jpg", "image/gif", "image/png").
                  rejecting('text/plain', 'text/xml') }
  end

  context 'factory'

  context 'LOOK UP methods' do
    before(:all) do
      @game = FactoryGirl.create(:midgame)
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

  end
end
