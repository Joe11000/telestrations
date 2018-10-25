require 'rails_helper'

RSpec.describe Card, type: :model do
  context 'factories' do
    context 'description cards', :r5 do
      it 'FactoryBot.create(:description)' do
        description = FactoryBot.create :description

        expect(description).to be_valid
        expect(description.drawing?).to eq false
        expect(description.description?).to eq true
        expect(description.medium).to eq 'description'
        expect(description.description_text).to be_a String
        expect(description.uploader).to be_a User
        expect(description.idea_catalyst).to be_nil
        expect(description.parent_card).to eq nil
        expect(description.starting_games_user).to be_a GamesUser
        expect(description.deleted_at).to eq nil
        expect(description.out_of_game_card_upload).to eq false
        expect(description.drawing.attached?).to eq false
        expect(description.child_card).to eq nil
        expect(description.placeholder).to eq false
      end
    end

    context 'drawing cards', :r5 do
      it 'FactoryBot.create(:drawing)', :r5 do
        drawing =  FactoryBot.create(:drawing)

        expect(drawing).to be_valid
        expect(drawing.drawing?).to eq true
        expect(drawing.description?).to eq false
        expect(drawing.medium).to eq 'drawing'
        expect(drawing.description_text).to eq nil
        expect(drawing.uploader).to be_a User
        expect(drawing.idea_catalyst).to be_nil
        expect(drawing.parent_card).to eq nil
        expect(drawing.starting_games_user).to be_a GamesUser
        expect(drawing.deleted_at).to eq nil
        expect(drawing.out_of_game_card_upload).to eq false
        expect(drawing.drawing.attached?).to eq true
        expect(drawing.child_card).to eq nil
        expect(drawing.placeholder).to eq false
      end
    end
  end

  context 'associations', :r5 do
    it {is_expected.to belong_to(:idea_catalyst).class_name("GamesUser").inverse_of(:starting_card)}
    it {is_expected.to belong_to(:parent_card).class_name('Card').inverse_of(:child_card)}
    it {is_expected.to belong_to(:starting_games_user).class_name('GamesUser')}
    it {is_expected.to belong_to(:starting_games_user).class_name('GamesUser')}
    it {is_expected.to have_one(:child_card).class_name('Card').inverse_of(:parent_card)} # .foreign_key(:parent_card_id)
    it {is_expected.to belong_to(:uploader).class_name('User')} #.foreign_key(:uploader_id)
    # it { is_expected.to have_one(:drawing) }
  end

  context 'db_columns', :r5 do
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


  context '#initialize_placeholder_card', :r5 do
    it "creates a drawing card if params passed a user_id and type = 'description'", :r5 do
      parent_card = FactoryBot.create(:drawing)
      user = FactoryBot.create :user

      card = Card.initialize_placeholder_card(user.id, 'description', parent_card.id)
      expect(card.persisted?).to eq false

      card.save

      expect(card.parent_card).to eq parent_card
      expect(card.child_card).to eq nil
      expect(card.drawing.attached?).to eq false
      expect(card.description_text).to eq nil
      expect(card.medium).to eq 'description'
      expect(card.uploader_id).to eq user.id
    end

    it "initializes a drawing card if params passed a user_id and medium = 'drawing'", :r5 do
      parent_card = FactoryBot.create(:description)
      user = FactoryBot.create :user

      card = Card.initialize_placeholder_card(user.id, 'drawing', parent_card.id)
      expect(card.persisted?).to eq false

      card.save

      expect(card.parent_card).to eq parent_card
      expect(card.child_card).to eq nil
      expect(card.drawing.attached?).to eq false
      expect(card.description_text).to eq nil
      expect(card.medium).to eq 'drawing'
      expect(card.uploader_id).to eq user.id
    end
  end
end
