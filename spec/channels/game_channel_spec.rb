require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  context '#subscribed' do

    before :each do
      @game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
      @current_user = @game.users.first
      stub_connection( current_user: @current_user )

      prev_card = ''
      channel   = 'GameChannel'
      @subscribe_params = { channel: channel, prev_card: prev_card}
    end


    it '' do
      subscribe @subscribe_params

      expect(streams).to eq ["game_#{@game.id}"]
    end
  end

  context 'upload_card', :r5_wip  do

    context 'user uploads first card' do
      context 'description card' do

        before :each do
          @game = FactoryBot.create :midgame_with_no_moves, callback_wanted: :midgame_with_no_moves
          @gu_1 = @game.games_users.first
          @current_user = @gu_1.user
          stub_connection( current_user: @current_user )

          prev_card = ''
          channel   = 'GameChannel'
          @subscribe_params = { channel: channel, prev_card: prev_card }

          subscribe @subscribe_params
        end

        it '' do
          description_text = 'user uploads first card description text'

          expect(ActionCable.server).to receive(:broadcast).with do |data|
            expect(data).to include ''
          end

          perform :upload_card, params: { prev_card: '', description_text: description_text }
          expect(gu_1.starting_card.description).to eq description_text
          expect(gu_1.starting_card.child_card).to be_a Card
          expect(gu_1.starting_card.child_card.drawing?).to eq true
          expect(gu_1.starting_card.child_card.drawing.attached?).to eq false
          expect(gu_1.starting_card.child_card.uploader_id).to be_in (@game.games_user_ids - [current_user.id])
        end
      end

      xcontext 'drawing card' do
      end
    end

    context 'user uploads a non final card' do
      context 'drawing'
      context 'description'
    end

    context 'user uploads a final card' do
      context 'drawing'
      context 'description'
    end
  end
end
