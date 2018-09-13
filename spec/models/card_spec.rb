require 'rails_helper'

RSpec.describe Card, type: :model do
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
  end
end
