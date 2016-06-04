require 'rails_helper'

RSpec.describe GamesUser, type: :model do

  it '#cards', working: true do
    game = FactoryGirl.create(:midgame)
    games_users = game.games_users

    expect(games_users.count).to eq 3

    expect(games_users.first.cards.ids).to eq [ games_users.first.starting_card.id ]
    expect(games_users.second.cards.ids).to eq [ games_users.second.starting_card.id, games_users.second.starting_card.child_card.id ]
    expect(games_users.third.cards.ids).to eq [ ]
  end
end
