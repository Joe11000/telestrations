class Game < ActiveRecord::Base
  # acts_as_paranoid

  has_many :games_users, inverse_of: :game, dependent: :destroy
  has_many :users, through: :games_users
  has_many :starting_cards, through: :games_users

  validates :join_code, uniqueness: true, length: { is: 4 }

  scope :active, -> { where(is_active: true) }
  scope :random_open_game, -> { active.where(is_private: false, allow_additional_players: true).sample }

  # this may get problematic if the number of groups playing gets a certain percentage close enough to 456976....not likely
  before_validation(on: :create) do
    active_codes = Game.active.pluck(:join_code)
    letters = ('A'..'Z').to_a
    new_code = ''

    while true
      4.times { new_code << letters.sample}

      unless active_codes.include?(new_code)
        self.join_code = new_code
        break
      end
    end
  end


# ie
# [
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
# ]
  def start_request

  end

  def self.all_users_game_names join_code
    GamesUser.includes(:game).where(games: { join_code: join_code }).map(&:users_game_name)
  end

  def cards_from_finished_game
    return [] if is_active

    # all cards associated with this games get
    starting_cards = Card.all_starting_cards.includes(idea_catalyst: :game).where(games: { join_code: join_code } )

    result = []

    starting_cards.each do |starting_card|
      card_set = []
      current_card = starting_card

      loop do
        uploaders_gamesuser = GamesUser.find_by(user_id: current_card.uploader_id, game_id: self.id)
        card_set << [ uploaders_gamesuser.users_game_name, current_card ]
        current_card = current_card.child_card
        break if current_card.nil?
      end

      result << card_set
    end
    result
  end

  # def join_request user
  #   if self.allow_additional_players

  #   else
  #     false
  #   end
  # end

  def prevent_additional_players
    # if user is NOT attached to a game, then return false
    byebug; self.users.find_by(user_id: current_user.id)
  end

end
