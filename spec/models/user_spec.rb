require 'rails_helper'

RSpec.describe User, type: :model do

  it { is_expected.to act_as_paranoid }
  it { is_expected.to have_many(:games).through(:games_users)}
  it { is_expected.to have_many(:starting_cards).through(:games_users)}
  it { is_expected.to have_many(:games_users) }

  context 'methods' do
    context 'User.all_unassociated_cards' do
      it 'valid if' do
        # associated card
        gu1 = FactoryGirl.create(:games_user)
        g1 = gu1.game
        u1 = gu1.user
        gu1.starting_card = FactoryGirl.create(:card, uploader_id: u1.id)
        c1 = gu1.starting_card

        # incorrect uploader
        gu2 = FactoryGirl.create(:games_user)
        g2 = gu2.game
        u2 = gu2.user
        gu2.starting_card = FactoryGirl.create(:card, uploader_id: u2.id)
        c2 = gu2.starting_card

        # no uploader
        gu3 = FactoryGirl.create(:games_user)
        g3 = gu3.game
        u3 = gu3.user
        gu3.starting_card = FactoryGirl.create(:card, uploader_id: nil)
        c3 = gu3.starting_card

        # no games_user association
        c4 = FactoryGirl.create(:card, uploader_id: u1.id)
        results = User.all_unassociated_cards

        session[:user_id] = u1.id

        expect(results.length).to eq 1
        expect(results.first).to eq c4

        byebug
      end
    end

    context '#current_game_name' do

    end
  end
end
