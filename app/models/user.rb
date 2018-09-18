class User < ActiveRecord::Base
  acts_as_paranoid

  has_one_attached :provider_avatar
  has_many :games_users, inverse_of: :user
  has_many :games, through: :games_users #, after_add: Proc.new { || self.current_game =  }
  has_one  :current_game, through: :games_users, class_name: 'Game'
  has_many :starting_cards, through: :games_users

  def current_game
    games.where(status: ['pregame', 'midgame']).order(id: :asc).try(:last) # || Game.none
  end

  def gamesuser_in_current_game
    GamesUser.includes(:game).where(user_id: id, games: { status: ['pregame', 'midgame']}).order(id: :asc).try(:last) # || nil
  end

  def starting_card_in_current_game
    gamesuser_in_current_game.try(:starting_card)
  end

  def users_game_name_in_current_game
    gamesuser_in_current_game.try(:users_game_name)
  end

end
