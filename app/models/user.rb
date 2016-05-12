class User < ActiveRecord::Base
  # acts_as_paranoid

  has_many :games_users, inverse_of: :user
  has_many :games, through: :games_users

  has_many :starting_cards, through: :games_users

  has_attached_file :provider_avatar_override, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                                               :default_url => "/images/:style/missing.png"
  validates_attachment :provider_avatar_override, content_type: { content_type: ["image/jpeg", "image/jpg", "image/gif", "image/png"] } # :content_type => /\Aimage\/.*\Z/
  validates_with AttachmentSizeValidator, :attributes => :provider_avatar_override, less_than: 5.megabytes

  def current_game
    games.not_postgames.last || Game.none
  end

  def gamesuser_in_current_game
    GamesUser.includes(:game).where.not(games: {status: 'postgame'}).find_by(user_id: id) || GamesUser.none
  end

  def starting_card_in_current_game
    gamesuser_in_current_game.try(:starting_card)
  end

  def users_game_name
    gamesuser_in_current_game.try(:users_game_name)
  end
end
