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
    Game.includes(:users).find_by(users: { id: id }, games: { is_active: true } )
  end

  def gamesuser_in_current_game
    GamesUser.includes(:game).find_by(user_id: id, games: {is_active: true})
  end

  def starting_card_in_current_game
    gamesuser_in_current_game.try(:starting_card)
  end

  def users_game_name
    gamesuser_in_current_game.try(:users_game_name)
  end

  def assign_player_to_game games_join_code, users_game_name
    association = gamesuser_in_current_game

    if current_game.try(:join_code) == games_join_code || # already attached to this game
      current_game.try(:active)                     # currently playing a game, but somehow got here
      return
    else
      # delete an association to another pregame game if it exists
      association.destroy unless association.blank?

      # create user association to game
      game = Game.find_by(join_code: games_join_code)
      GamesUser.create(user_id: id, game_id: game.id, users_game_name: users_game_name)
    end
  end

  def leave_current_game
    gamesuser = self.gamesuser_in_current_game
    return if gamesuser.blank?
    game = gamesuser.game

    unless game.join_code.blank?
      if game.users.size == 1
        game.destroy
      else
        gamesuser.destroy
      end
    end
  end
end
