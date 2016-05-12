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

  def rendezvous_with_game join_code
    cg = current_game

    if !cg.blank? && cg.try(:join_code) == join_code # player is already rendezvousing with Game
      return
    elsif ( cg.try(:status) == 'pregame' ) # player rendezvousing with another game
      gamesuser_in_current_game.destroy
    end

    self.games << Game.find_by(join_code: join_code)
  end

  def commit_to_game join_code, users_game_name
    gu = gamesuser_in_current_game
    return if gu.blank?
    gu.update(users_game_name: users_game_name);
  end

  def leave_current_game
    cg = current_game
    return false if (cg.blank? || cg.status != 'pregame')

    if cg.users.count == 1
      cg.destroy
    else
      gamesuser_in_current_game.try(:destroy)
    end

    true
  end
end
