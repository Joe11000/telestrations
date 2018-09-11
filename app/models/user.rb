class User < ActiveRecord::Base
  acts_as_paranoid

  has_many :games_users, inverse_of: :user
  has_many :games, through: :games_users #, after_add: Proc.new { || self.current_game =  }
  has_one  :current_game, through: :games_users, optional: true

  has_many :starting_cards, through: :games_users

  def current_game
    games.order(:id).last || Game.none
  end

  def gamesuser_in_current_game
    GamesUser.includes(:game).where(user_id: id).order(:id).try(:last) || GamesUser.none
  end

  def starting_card_in_current_game
    gamesuser_in_current_game.try(:starting_card)
  end

  def users_game_name
    gamesuser_in_current_game.try(:users_game_name)
  end

  def unassociated_cards
    Card.where(uploader_id: id, starting_games_user_id: nil, idea_catalyst_id: nil).order(:id)
  end

end
