class User < ActiveRecord::Base
  # acts_as_paranoid
  # has_secure_password

  has_many :games_users, inverse_of: :user
  has_many :games, through: :games_users

  has_many :starting_cards, through: :games_users

  has_attached_file :provider_avatar_override, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment :provider_avatar_override, content_type: { content_type: ["image/jpeg", "image/jpg", "image/gif", "image/png"] }
  # validates_attachment_content_type :drawing, :content_type => /\Aimage\/.*\Z/

  scope :current_game, -> { Game.includes(:users).where(users: { id: current_user.id }, games: { is_active: true } ) }
  scope :current_gamesuser, -> { GamesUser.select(:users_game_name).includes(:game).where(user_id: self.id, game: {is_active: true}) }

  def unassociated_cards # users cards not uploaded while in a game
    Card.where(games_users: nil, uploader_id: current_user.id)
  end

  def users_game_name
    current_gamesuser.try(:users_game_name)
  end

  def leave_current_game
    gamesuser = self.current_gamesuser
    return if gamesuser.blank?
    game = gamesuser.game

    if game.allow_additional_players
      if game.users.size == 1
        game.destroy
      else
        gamesuser.destroy
      end
    end
  end
end
