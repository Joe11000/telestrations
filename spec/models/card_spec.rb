require 'rails_helper'

RSpec.describe Card, type: :model do
  context 'factories' do
    context 'description', :r5_wip do
      it 'description' do
        description = FactoryBot.create :description

        expect(description).to be_valid
        expect(description.medium).to eq 'description'
        expect(description.description_text).to be_a String
        expect(description.uploader).to be_a User
        expect(description.idea_catalyst).to be_nil
      end

      it 'users_starting_description_card', :r5_wip do
        description = FactoryBot.create :description

        expect(description).to be_valid
        expect(description.medium).to eq 'description'
        expect(description.description_text).to be_a String
        expect(description.uploader).to eq description.idea_catalyst
      end
    end

    context 'drawing' do
      it 'description'
      it 'users_starting_drawing_card'
    end

  end

  context 'associations', r5: true do
    it {is_expected.to belong_to(:idea_catalyst).class_name("GamesUser").inverse_of(:starting_card)}
    it {is_expected.to belong_to(:parent_card).class_name('Card').inverse_of(:child_card)}
    it {is_expected.to belong_to(:starting_games_user).class_name('GamesUser')}
    it {is_expected.to belong_to(:starting_games_user).class_name('GamesUser')}
    it {is_expected.to have_one(:child_card).class_name('Card').inverse_of(:parent_card)} # .foreign_key(:parent_card_id)
    it {is_expected.to belong_to(:uploader).class_name('User')} #.foreign_key(:uploader_id)
    # it { is_expected.to have_one(:drawing) }
  end

  context 'db_columns', r5: true do
    it { is_expected.to act_as_paranoid }
    it { is_expected.to have_db_column(:uploader_id).of_type(:integer) }
    it { is_expected.to have_db_column(:parent_card_id).of_type(:integer) }
    it { is_expected.to have_db_column(:starting_games_user_id).of_type(:integer) }
    it { is_expected.to have_db_column(:idea_catalyst_id).of_type(:integer) }
    it { is_expected.to have_db_column(:description_text).of_type(:text) }
    it { is_expected.to have_db_column(:medium).of_type(:integer).with_options(default: 'drawing') }
    it { is_expected.to have_db_column(:deleted_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:out_of_game_card_upload).of_type(:boolean).with_options(default: false, null: false) }

    it { is_expected.to have_db_index(:deleted_at) }
    it { is_expected.to have_db_index(:idea_catalyst_id) }
    it { is_expected.to have_db_index(:parent_card_id) }
    it { is_expected.to have_db_index(:starting_games_user_id) }
    it { is_expected.to have_db_index(:uploader_id) }
  end

  context 'scopes' do
    context 'Card.cards_independent_of_a_game' do
      it 'valid if' do
        # associated card
        gu1 = FactoryBot.create(:games_user)
        g1 = gu1.game
        u1 = gu1.user
        gu1.starting_card = FactoryBot.create(:drawing, uploader_id: u1.id)
        c1 = gu1.starting_card

        # incorrect uploader
        gu2 = FactoryBot.create(:games_user)
        g2 = gu2.game
        u2 = gu2.user
        gu2.starting_card = FactoryBot.create(:drawing, uploader_id: u2.id)
        c2 = gu2.starting_card

        # no uploader
        gu3 = FactoryBot.create(:games_user)
        g3 = gu3.game
        u3 = gu3.user
        gu3.starting_card = FactoryBot.create(:drawing, uploader_id: nil)
        c3 = gu3.starting_card

        # no games_user association
        c4 = FactoryBot.create(:drawing, uploader_id: u1.id)

        results = Card.cards_independent_of_a_game u1.id

        expect(results.length).to eq 1
        expect(results.first).to eq c4
      end
    end


    it '#out_of_game_card_upload' do
      current_user = @game.users.order(:id).first
      random_games_user = FactoryBot.create :games_user
      card_to_find_1 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: nil, idea_catalyst_id: nil)
      card_to_find_2 = FactoryBot.create(:description, uploader: current_user, starting_games_user: nil, idea_catalyst_id: current_user)
      card_to_find_3 = FactoryBot.create(:drawing, uploader: current_user, starting_games_user: random_games_user, idea_catalyst_id: nil)
      card_to_find_4 = FactoryBot.create(:description, uploader: current_user, starting_games_user: random_games_user, idea_catalyst_id: current_user)

      expect(Card.out_of_game_card_upload(current_user.id)).to eq [ card_to_find_1 ]
    end
  end


end
