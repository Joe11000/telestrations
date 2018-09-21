# module RendezvousChannel
#   # 3 players rendezvousing on game and logged in as user_1
#   def self.rendezvous user: nil, game: FactoryBot.create(:game, :pregame), bnding:
#     user = game.users.first
#     byebug
#     stub_connection( current_user: user )
#     subscribe join_code: game.join_code
#     return({game: game, user: user})
#   end


# end
