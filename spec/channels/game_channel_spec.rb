require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  context '#subscribed', :r5_wip do
    @game = FactoryBot.create :game, :midgame_with_no_moves

    stub_connection {current_user: @game.users}
  end
end
