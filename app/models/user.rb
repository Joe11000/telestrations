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
    Game.includes(:users).not_postgames.find_by(users: { id: id })
  end

  def gamesuser_in_current_game
    GamesUser.includes(:game).find_by(user_id: id, games: { status: ['pregame', 'midgame' ] })
  end

  def starting_card_in_current_game
    gamesuser_in_current_game.try(:starting_card)
  end

  def users_game_name
    gamesuser_in_current_game.try(:users_game_name)
  end

  def assign_player_to_game game_id, users_game_name
    byebug
    cg = current_game
    if cg.try(:id) == game_id || # already attached to this game
      cg.try(:status) == 'midgame'  # currently playing a game, but somehow got here
      return
    else

      # delete an association to another pregame game if it exists
      association = gamesuser_in_current_game
      association.destroy unless association.blank?

      # create user association to game
      game = Game.find(game_id)
      GamesUser.create(user_id: id, game_id: game.id, users_game_name: users_game_name)
    end
  end

  def leave_current_game
    cg = current_game
    return false if (cg.blank? || cg.status != 'pregame')

    if cg.users.count == 1
      cg.destroy
    else
      gamesuser_in_current_game.destroy
    end

    true
  end
end
