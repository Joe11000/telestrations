# require 'bcrypt'

class User < ActiveRecord::Base
  # include BCrypt

  # acts_as_paranoid
  # has_secure_password

  has_many :games_users, inverse_of: :user
  has_many :games, through: :games_users

  has_many :starting_cards, through: :games_users

  has_attached_file :provider_avatar_override, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment :provider_avatar_override, content_type: { content_type: ["image/jpeg", "image/jpg", "image/gif", "image/png"] }
  # validates_attachment_content_type :drawing, :content_type => /\Aimage\/.*\Z/

  def unassociated_cards # users cards not uploaded while in a game
    Card.where(games_users: nil, uploader_id: current_user.id)
  end

  def users_game_name
    gamesuser_of_active_game.try(:users_game_name)
  end

  def gamesuser_of_active_game
    GamesUser.select(:users_game_name).includes(:game).where(user_id: self.id, game: {is_active: true})
  end
end
