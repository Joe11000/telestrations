require 'spec_helper'
require 'rails_helper'

RSpec.describe Game, type: :model do

  xcontext 'model validations' do
    it { is_expected.to have_many(:games_users).inverse_of(:game).dependent(:destroy) }
  end

  context 'factory' do

    it ':game is valid' do
      expect(FactoryGirl.create(:game).valid?).to eq true
    end

    context ':full_game' do
      before :all do
        @full_game = FactoryGirl.create(:full_game)
      end

      it 'is valid' do
        #byebug
        expect(FactoryGirl.create(:full_game).valid?).to eq true
      end

      it 'has correct associations' do
        expect(@full_game.users.count).to eq 3

        @full_game.users.each do |user|
          expect(user.starting_cards.length).to eq 1
          expect(user.starting_cards.first.child_card.parent_card).to eq user.starting_cards.first
        end
      end

      it 'status' do
        expect(@full_game.status).to eq 'midgame'
      end

      it 'removes join code' do
        expect(@full_game.join_code).to eq nil
      end
    end


    context ':post_game' do
      before :all do
        @post_game = FactoryGirl.create(:post_game)
      end

      it 'is valid' do
        expect(@post_game.valid?).to eq true
      end

      it 'has correct associations' do
        expect(@post_game.users.count).to eq 3

        @post_game.users.each do |user|
          expect(user.starting_cards.length).to eq 1
          expect(user.starting_cards.first.child_card.parent_card).to eq user.starting_cards.first
        end
      end

      it 'status' do
        expect(@post_game.status).to eq 'postgame'
      end

      it 'does not allow additional players' do
        expect(@post_game.join_code).to eq nil
      end
    end

    context 'public_pre_game' do
      before :all do
        @public_pre_game = FactoryGirl.create(:public_pre_game)
      end

      it 'has 3 users attached' do
        expect(@public_pre_game.users.count).to eq 3
      end

      it 'is a public game' do
        expect(@public_pre_game.is_private).to eq false
      end

      it 'allows additional players' do
        expect(@public_pre_game.join_code).to match /^[a-zA-Z]{4}$/
      end

      it 'game has not been completed' do
        expect(@public_pre_game.status).to eq 'pregame'
      end

      it 'game has not been deleted for some strange reason' do
        expect(@public_pre_game.deleted_at).to eq nil
      end
    end
  end

  context 'basic instantiation' do
    let(:game){FactoryGirl.create(:game)}

    before(:each) do
      Game.delete_all
    end

    it 'is_private is set to true' do
      expect(game.is_private).to eq true
    end

    it 'status is defaulted to pregame' do
      expect(game.status).to eq 'pregame'
    end

    it 'a 4 digit join_code' do
      10.times{ FactoryGirl.create(:game)}
      expect(Game.pluck(:join_code).length).to eq 10
    end
  end

  context 'scope' do
    it 'random_public_game' do
      Game.destroy_all
      g1 = FactoryGirl.create(:public_pre_game)
      g3 = FactoryGirl.create(:public_pre_game, is_private: true)
      g3 = FactoryGirl.create(:public_pre_game, join_code: nil)

      expect(Game.random_public_game).to eq g1
      expect(Game.random_public_game).to eq g1 # intentionally duplicated test
    end


  end

  context 'methods' do
    context '#cards_formatted' do
      before(:all) do
        @game = FactoryGirl.create(:post_game)
        @cards = @game.cards_formatted
      end

      it 'returns correct ordering of cards' do
        first_user, second_user, third_user = @game.users

        first_starting_card, second_starting_card, third_starting_card = @game.starting_cards

        expect(@cards).to eq [
                                [
                                  [first_starting_card.uploader.games_users.first.users_game_name, first_starting_card ],
                                  [first_starting_card.child_card.uploader.users_game_name, first_starting_card.child_card ],
                                  [first_starting_card.child_card.child_card.uploader.users_game_name, first_starting_card.child_card.child_card ]
                                ],
                                [
                                  [second_starting_card.uploader.games_users.first.users_game_name, second_starting_card ],
                                  [second_starting_card.child_card.uploader.users_game_name, second_starting_card.child_card ],
                                  [second_starting_card.child_card.child_card.uploader.users_game_name, second_starting_card.child_card.child_card ]
                                ],
                                [
                                  [third_starting_card.uploader.games_users.first.users_game_name, third_starting_card ],
                                  [third_starting_card.child_card.uploader.users_game_name, third_starting_card.child_card ],
                                  [third_starting_card.child_card.child_card.uploader.users_game_name, third_starting_card.child_card.child_card ]
                                ]
                             ]

      end
    end

    context '#remove_player' do
      context 'does nothing and returns false if' do
        it 'user does not exist' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.remove_player invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user not associated with game' do
          game = FactoryGirl.create(:public_pre_game)
          random_user = FactoryGirl.create(:user)

          user_ids = game.users.ids
          random_user_id = random_user.id

          expect(game.remove_player random_user_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end
      end

      context 'if other users are rendezvouing' do
        it 'removes only the user' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          valid_id = user_ids.first

          expect(game.remove_player valid_id).to eq true
          game.reload
          expect(game.users.ids).to eq user_ids.last(2)
        end
      end

      context 'if NO other users are rendezvouing' do
        it 'removes the user and the game' do
          game = FactoryGirl.create(:public_pre_game)
          user = game.users.first
          game.users.where.not(id: user.id).destroy_all


          expect(game.remove_player user.id).to eq true
          expect(user.current_game).to eq Game.none
          expect(game.destroyed?).to eq true
        end
      end
    end

    context '#rendezvous_a_new_user' do
      context 'does nothing and returns false if' do
        it 'user doesnt exist' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          invalid_id = (User.ids.last + 1)

          expect(game.rendezvous_a_new_user invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'user is already associated with game' do
          game = FactoryGirl.create(:public_pre_game)
          user_ids = game.users.ids
          invalid_id = User.ids.first

          expect(game.rendezvous_a_new_user invalid_id).to eq false
          game.reload
          expect(game.users.ids).to eq user_ids
        end

        it 'player playing another game' do
          user_associated_game = FactoryGirl.create(:full_game)
          new_game = FactoryGirl.create(:public_pre_game)
          user = user_associated_game.users.last

          user_associated_game_user_ids = user_associated_game.users.ids
          new_game_user_ids = new_game.users.ids

          expect(new_game.rendezvous_a_new_user user.id).to eq false
          new_game.reload
          expect(new_game.users.ids).to eq new_game_user_ids
          expect(user_associated_game.users.ids).to eq user_associated_game_user_ids
        end

        it 'the game is not in pregame mode'
      end

      context 'creates a GamesUser association from game to the new player' do

      end
    end
  end
end
