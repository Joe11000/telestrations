require 'spec_helper'
require 'rails_helper'

RSpec.describe Game, type: :model do

  context 'factory' do
    it 'is valid' do
      FactoryGirl.create(:game).valid?
    end

    it 'is valid' do
      FactoryGirl.create(:post_game).valid?
    end

    it 'post_game' do
      @post_game = FactoryGirl.create(:post_game).valid?

      expect(@post_game.users.count).eq 3

      @user = @post_game.users.first
      expect(@user.starting_card).to eq 3
      expect(@user.starting_card.child_card.parent_card).to eq @post_game.users.first.starting_card

      @user = @post_game.users.first(2).last
      expect(@user.starting_card).to eq 3
      expect(@user.starting_card.child_card.parent_card).to eq @post_game.users.first.starting_card

      @user = @post_game.users.last
      expect(@post_game.users.first(2).last.starting_cards.length).to eq 3
      expect(@post_game.users.last.starting_cards.length).to eq 3
    end
  end

  context 'model validations' do
    it { is_expected.to validate_uniqueness_of(:join_code) }
    it { is_expected.to validate_length_of(:join_code).is_equal_to(4) }
    it { is_expected.to have_many(:games_users) }
    it { is_expected.to act_as_paranoid }
  end

  context 'basic instantiation' do
    let(:game){FactoryGirl.create(:game)}

    before(:each) do
      Game.delete_all
    end

    it 'is_private is set to true' do
      expect(game.is_private).to eq true
    end

    it 'is_active is set to true' do
      expect(game.is_active).to eq true
    end

    it 'a 4 digit join_code' do
      10.times{ FactoryGirl.create(:game)}
      expect(Game.pluck(:join_code).length).to eq 10
    end
  end

  context 'methods' do
    it '#active' do
      Game.delete_all
      g = FactoryGirl.create(:game)
      FactoryGirl.create(:game, is_active: false)

      result = Game.active
      expect(result.length).to eq 1
      expect(result.first).to eq g
    end


    context '#cards_from_finished_game' do
      context 'returns correct ordering of cards if' do
        before(:all) do
          @game = FactoryGirl.create(:post_game)
        end

        it 'picture card is first' do
          cards = @game.cards_from_finished_game

          expect(@game.users.size).to eq 3

          # @first_user = @game.users.first
          # @second_user = @game.users.first(2).last
          # @third_user = @game.users.last


          first_starting_card = @game.starting_cards.first
          second_starting_card = @game.starting_cards.first(2).last
          third_starting_card = @game.starting_cards.last

          byebug
          expect(cards).to eq [
                                [
                                  [first_starting_card.uploader.users_game_name, first_starting_card ],
                                  [first_starting_card.child_card.uploader.users_game_name, first_starting_card.child_card ],
                                  [first_starting_card.child_card.child_card.uploader.users_game_name, first_starting_card.child_card.child_card ]
                                ],
                                [
                                  [second_starting_card.uploader.users_game_name, second_starting_card ],
                                  [second_starting_card.child_card.uploader.users_game_name, second_starting_card.child_card ],
                                  [second_starting_card.child_card.child_card.uploader.users_game_name, second_starting_card.child_card.child_card ]
                                ],
                                [
                                  [third_starting_card.uploader.users_game_name, third_starting_card ],
                                  [third_starting_card.child_card.uploader.users_game_name, third_starting_card.child_card ],
                                  [third_starting_card.child_card.child_card.uploader.users_game_name, third_starting_card.child_card.child_card ]
                                ]
                              ]
        end
        it 'description card is first' do

        end
      end
    end
  end
end
