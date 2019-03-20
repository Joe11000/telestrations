class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password

  has_one_attached :provider_avatar
  has_many :games_users, ->{ order(id: :asc) }, inverse_of: :user
  has_many :games, ->{ order(id: :asc) }, through: :games_users #, after_add: Proc.new { || self.current_game =  }
  has_one  :current_game, through: :games_users, class_name: 'Game'
  has_many :starting_cards, ->{ order(id: :asc) },  through: :games_users

  validates :email, presence: true
  validates :password_digest, presence: true

  def current_game
    games.where(status: ['pregame', 'midgame']).order(id: :asc).try(:last) # || Game.none
  end

  def current_games_user
    GamesUser.includes(:game).where(user_id: id, games: { status: ['pregame', 'midgame']}).order(id: :asc).try(:last) # || nil
  end

  def current_starting_card
    current_games_user.try(:starting_card)
  end

  def current_games_user_name
    current_games_user.try(:users_game_name)
  end

end
