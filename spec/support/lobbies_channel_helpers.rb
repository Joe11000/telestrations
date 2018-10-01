# module LobbyChannel
#   # 3 players lobbying on game and logged in as user_1
#   def self.lobby user: nil, game: FactoryBot.create(:pregame, callback_wanted: :pregame), bnding:
#     user = game.users.first
#
#     stub_connection( current_user: user )
#     subscribe join_code: game.join_code
#     return({game: game, user: user})
#   end


# end
