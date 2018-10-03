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
end
