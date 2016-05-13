class Game < ActiveRecord::Base
  has_many :games_users, inverse_of: :game, dependent: :destroy
  has_many :users, through: :games_users
  has_many :starting_cards, through: :games_users

  validates :join_code, uniqueness: true, length: { is: 4 }, if: Proc.new { !join_code.blank? }
  validates :status, inclusion: { in: %w( pregame midgame postgame ) }

  scope :pregames, -> { where(status: 'pregame') }
  scope :midgames, -> { where(status: 'midgame') }
  scope :postgames, -> { where(status: 'postgame') }
  scope :not_postgames, -> { where.not(status: 'postgame') }
  scope :public_games, -> { where(is_private: false) }

  def self.random_public_game
    Game.pregames.public_games.sample
  end

  # this may get problematic if the number of groups playing gets a certain percentage close enough to 456976....not likely
  before_validation(on: :create) do
    active_codes = Game.not_postgames.pluck(:join_code)
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

  def unassociated_rendezousing_games_users
    GamesUser.where(game_id: id, users_game_name: nil)
  end

  # could use but haven't
  # def associated_rendezousing_games_users
  #   GamesUser.includes(:user, :game).where(games: {id: id }).where.not(games_users: {users_game_name: nil})
  # end



# ie
# [
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
# ]


  def rendezvous_a_new_user user_id
    user = User.find_by(id: user_id)
    user_current_game = user.try(:current_game)

    if  user.blank? ||                        # player doesn't exist or
        users.find_by(id: user.id) ||         # player already rendezvousing with game
        user_current_game.try(:status) == 'midgame' || # c) player is currently in the middle of a game
        status != 'pregame'
      return false

    elsif user_current_game.try(:status) == 'pregame'
      # current game is not underway or over
      user.gamesuser_in_current_game.destroy
    end

    self.users << user
    true
  end

  # def commiting_user join_code, users_game_name

  # def commit_to_game join_code, users_game_name
  #   gu = gamesuser_in_current_game
  #   return if gu.blank?
  #   gu.update(users_game_name: users_game_name);
  # end

  def remove_player user_id
    user = users.find_by(id: user_id)
    return false if (user.blank? || status != 'pregame')

    if users.count == 1
      self.destroy
    else
      games_users.find_by(user_id: user_id, game_id: id).destroy
    end

    true
  end





  def self.all_users_game_names join_code
    GamesUser.includes(:game).where(games: { join_code: join_code }).map(&:users_game_name)
  end

  def cards_from_finished_game
    return [] if is_post_game?

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
  # FactoryGirl.create(:full_game)
# Game.last.update(status: 'pregame')
# Game.last.remove_player(Game.last.users.first)
end
