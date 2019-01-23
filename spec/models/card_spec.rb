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


    context '.cards_from_finished_game', :r5 do
      before(:all) do
        @game = FactoryBot.create(:postgame, callback_wanted: :postgame)
        FactoryBot.create(:drawing, out_of_game_card_upload: true)
        FactoryBot.create(:midgame, callback_wanted: :midgame)
        FactoryBot.create(:midgame, :public_game, callback_wanted: :midgame)
        FactoryBot.create(:postgame, :public_game, callback_wanted: :postgame)

        @cards = Card.cards_from_finished_game @game.id
      end

      it 'returns correct ordering of cards', :r5, focus: true do
        gu1, gu2, gu3 = @game.games_users
        starting_card1, starting_card2, starting_card3 = @game.games_users.map(&:starting_card)

          byebug

        expect(@cards).to match_array [
                                        [
                                          [starting_card1.uploader.games_users.last.users_game_name, starting_card1.attributes ],
                                          [starting_card1.child_card.uploader.games_users.last.users_game_name, starting_card1.child_card.attributes ],
                                          [starting_card1.child_card.child_card.uploader.games_users.last.users_game_name, starting_card1.child_card.child_card.attributes ]
                                        ],
                                        [
                                          [starting_card2.uploader.games_users.last.users_game_name, starting_card2.attributes],
                                          [starting_card2.child_card.uploader.games_users.last.users_game_name, starting_card2.child_card.attributes],
                                          [starting_card2.child_card.child_card.uploader.games_users.last.users_game_name, starting_card2.child_card.child_card.attributes ]
                                        ],
                                        [
                                          [starting_card3.uploader.games_users.last.users_game_name, starting_card3.attributes ],
                                          [starting_card3.child_card.uploader.games_users.last.users_game_name, starting_card3.child_card.attributes ],
                                          [starting_card3.child_card.child_card.uploader.games_users.last.users_game_name, starting_card3.child_card.child_card.attributes ]
                                        ]
                                      ]
        @cards.each do |gu|
          byebug
          expect(gu[1][0].drawing_url).to eq nil
          expect(gu[1][1].drawing_url).to be_a String
          expect(gu[1][2].drawing_url).to eq nil
        end
      end
    end

  context '.get_placeholder_card', :r5 do
    context '> 1 placeholder available' do
      it 'returns earliest a placeholder card queued'  do
        game = FactoryBot.create(:midgame, callback_wanted: :midgame)
        random_placeholder1 = FactoryBot.create(:drawing, :placeholder)
        random_placeholder2 = FactoryBot.create(:description, :placeholder)
        random_placeholder3 = FactoryBot.create(:description, :placeholder)
        FactoryBot.create(:drawing, out_of_game_card_upload: true)

        gu1, gu2, gu3 = game.games_users.order(id: :asc) # simulates each of the stacks of paper being passed
        user_1, user_2, user_3 = gu1.user, gu2.user, gu3.user

        # placeholder for each one the decks
        gu1_placeholder = gu1.starting_card.child_card
        gu2_placeholder = gu2.starting_card.child_card
        gu3_placeholder = gu3.starting_card.child_card.child_card


        expect(Card.get_placeholder_card(user_1.id, game)).to eq nil

        # start user 2 has 2 placeholders, so test for both
          expect(Card.get_placeholder_card(user_2.id, game)).to eq gu1_placeholder
          gu1_placeholder.drawing.attach(io: File.open(File.join(Rails.root, 'spec', 'support', 'images', 'thumbnail_selfy.jpg')), \
                                         content_type: 'image/jpg', \
                                         filename: 'provider_avatar.jpg')
          gu1_placeholder.update(placeholder: false)
          expect(Card.get_placeholder_card(user_2.id, game)).to eq gu3_placeholder
        # end user 2 has 2 placeholders, so test for both

        expect(Card.get_placeholder_card(user_3.id, game)).to eq gu2_placeholder
      end
    end

    context '1 placeholder available' do
      it 'returns find a placeholder card' do
        game = FactoryBot.create(:midgame_with_no_moves, callback_wanted: :midgame_with_no_moves)
        random_placeholder1 = FactoryBot.create(:drawing, :placeholder)
        random_placeholder2 = FactoryBot.create(:description, :placeholder)
        random_placeholder3 = FactoryBot.create(:description, :placeholder)
        FactoryBot.create(:drawing, out_of_game_card_upload: true)

        gu1, gu2, gu3 = game.games_users.order(id: :asc)

        gu1_placeholder = gu1.starting_card
        gu2_placeholder = gu2.starting_card
        gu3_placeholder = gu3.starting_card

        expect(Card.get_placeholder_card( gu1.user_id, game)).to eq gu1_placeholder
        expect(Card.get_placeholder_card( gu2.user_id, game)).to eq gu2_placeholder
        expect(Card.get_placeholder_card( gu3.user_id, game)).to eq gu3_placeholder
      end
    end

    context 'no placeholder available' do
      it 'for pregames' do
        FactoryBot.create(:pregame, callback_wanted: :pregame)
        game = FactoryBot.create(:pregame, callback_wanted: :pregame)
        random_placeholder1 = FactoryBot.create(:drawing, :placeholder)
        random_placeholder2 = FactoryBot.create(:description, :placeholder)
        random_placeholder3 = FactoryBot.create(:description, :placeholder)
        FactoryBot.create(:drawing, out_of_game_card_upload: true)

        gu1, gu2, gu3 = game.games_users
        expect( Card.get_placeholder_card(gu1.user_id, game) ).to eq nil
        expect( Card.get_placeholder_card(gu2.user_id, game) ).to eq nil
        expect( Card.get_placeholder_card(gu3.user_id, game) ).to eq nil
      end

      it 'for postgames' do
        FactoryBot.create(:pregame, callback_wanted: :pregame)
        game = FactoryBot.create(:postgame, callback_wanted: :postgame)
        random_placeholder1 = FactoryBot.create(:drawing, :placeholder)
        random_placeholder2 = FactoryBot.create(:description, :placeholder)
        random_placeholder3 = FactoryBot.create(:description, :placeholder)
        FactoryBot.create(:drawing, out_of_game_card_upload: true)

        gu1, gu2, gu3 = game.games_users
        expect( Card.get_placeholder_card(gu1.user_id, game) ).to eq nil
        expect( Card.get_placeholder_card(gu2.user_id, game) ).to eq nil
        expect( Card.get_placeholder_card(gu3.user_id, game) ).to eq nil
      end
    end
  end

end
