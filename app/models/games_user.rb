class GamesUser < ActiveRecord::Base
  # acts_as_paranoid

  belongs_to :user
  belongs_to :game

  has_one :starting_card, class_name: 'Card',
                          foreign_key: :idea_catalyst_id

  has_many :cards

  # def is_set_complete?
  #   counter = 0

  #   card = starting_card

  #   loop do
  #     break if card.blank?
  #     counter += 1
  #     card = card.child_card
  #   end

  #   game.parse_passing_order.length == counter
  # end
end
