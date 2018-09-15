class Card < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :idea_catalyst, class_name: 'GamesUser', inverse_of: :starting_card, optional: true # signifies this card is a starting card in a game. Because trying to find all starting cards was harder before doing this
  belongs_to :parent_card, class_name: 'Card', inverse_of: :child_card, optional: true
  belongs_to :starting_games_user, class_name: 'GamesUser', optional: true
  belongs_to :uploader, foreign_key: :uploader_id, class_name: 'User'

  enum medium: %w( drawing description )

  has_one  :child_card, class_name: 'Card', foreign_key: :parent_card_id, inverse_of: :parent_card
  has_one_attached :drawing

  scope :all_starting_cards, -> { where.not(cards: { idea_catalyst_id: nil}) }
end
