class Card < ApplicationRecord
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
    game_ids.map { |game_id| self.cards_from_finished_game(game_id) }
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
        desired_card_attributes = card.drawing? ? self.attributes_of_drawing_card(card) : self.attributes_of_description_card(card)
        gu_set << [ GamesUser.find_by(game_id: game_id, user_id: card.uploader_id).users_game_name, desired_card_attributes ]
        card = card.child_card
      end
       result << gu_set
    end
    result
  end

  # retrieve all postgame attributes for  
  def self.get_desired_out_of_game_card_attributes current_user
    byebug
    ordered_drawings = drawing.where(uploader: current_user, out_of_game_card_upload: true).order(created_at: :desc)
    return [] if ordered_drawings.blank?
    
    result = ordered_drawings.map do |card|
      [ "", { 'drawing_url' => card.get_drawing_url } ] # return "" first because there is no users_game_name from a game that didn't exist 
    end

    [result]
  end


  # r5 tested
  # find the earliest placeholder created for user
  def self.get_placeholder_card current_user_id, game
    result = Card.where(placeholder: true, uploader_id: current_user_id, starting_games_user_id: game.games_users.ids).order(id: :asc).try(:first)

    return result || nil
  end


  include Rails.application.routes.url_helpers
  def get_drawing_url
    unless (drawing? && drawing.attached?)
      raise 'Card must be a drawing with an image attached'
    end

    return rails_blob_path(drawing, disposition: 'attachment', only_path: true)
  end

  private 
    def self.attributes_of_drawing_card card
      card.attributes.except('created_at', 'deleted_at', 'updated_at').merge!({ 'drawing_url' => card.get_drawing_url })
    end

    def self.attributes_of_description_card card
      card.attributes.except('created_at', 'deleted_at', 'updated_at')
    end

end
