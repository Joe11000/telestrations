# class CreateCardsInAdvance
#   include Sidekiq::Worker

#   def perform(game_id, passing_order, description_first=true)
#     logger.notice << 'Passing Order : #{passing_order}. ' + (description_first ? 'Description' : 'Drawing') + ' first.'

#     game = Game.find_by(game_id).includes(:users)

#     unless game.blank?

#       size = self.users.count
#       for starting_user_index in 0...size
#         card_medium = description_first ? 'description' : 'drawing'
#         starting_gamesuser = GamesUser.find_by(user_id: passing_order[starting_user_index], game_id: id)
#         parent_card = starting_gamesuser.starting_card = Card.create(type: card_medium, uploader_id: passing_order[starting_user_index])

#         for passed_to_index in 1...size
#           uploader_id =  passing_order[ (starting_user_index + passed_to_index) % size ]
#           parent_card.child_card = Card.create(type: card_medium, uploader_id: uploader_id)
#           card_medium = (card_medium.medium)
#         end
#       end

#     end
#   end
# end
