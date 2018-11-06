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

  def self.initialize_placeholder_card uploader_id, medium, parent_card_id=nil
    return Card.new( medium: medium,
                     uploader_id: uploader_id,
                     parent_card_id: parent_card_id,
                     placeholder: true)
  end



  def self.cards_from_finished_games game_ids
    result = []
    game_ids.each do |game_id|
      result << self.cards_from_finished_game(game_id)
    end
    result
  end

    # r5 tested
  # postgame public methods
  def self.cards_from_finished_game game_id
    game = Game.includes(games_users: {starting_card: {child_card: :child_card  } }).find(game_id)
    result = []
    return result unless game.postgame?

    game.games_users.each do |gu|
      gu_set = []
      card = gu.starting_card

      until card.blank? do
        gu_set << [ GamesUser.find_by(game_id: game_id, user_id: card.uploader_id).users_game_name, card ]
        card = card.child_card
      end

       result << gu_set
    end

    result
  end



  # r5 tested
  # find the earliest placeholder created for user
  def self.get_placeholder_card current_user_id, game
    result = Card.where(placeholder: true, uploader_id: current_user_id, starting_games_user_id: game.games_users.ids).order(id: :asc).try(:first)

    return result || nil
  end
end
