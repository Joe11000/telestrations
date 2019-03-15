class Game < ApplicationRecord
  include Rails.application.routes.url_helpers

  has_many :games_users, ->{ order(id: :asc) }, inverse_of: :game, dependent: :destroy
  has_many :users, ->{ order(id: :asc) }, through: :games_users
  has_many :starting_cards, ->{ order(id: :asc) }, through: :games_users

  validates :join_code, uniqueness: true, length: { is: 4 }, if: Proc.new { !join_code.blank? }

  enum status: %w( pregame midgame postgame )
  enum game_type: %w( public private ), _suffix: :game

  # this may get problematic if the number of groups playing gets a certain percentage close enough to 456976....not likely
  before_validation(on: :create) do
    active_codes = Game.where(status: ['pregame', 'midgame']).pluck(:join_code)
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

  def is_player_finished? user_id
    raise 'Game must be midgame' unless midgame?
    next_player = next_player_after(user_id)

    return next_player.current_games_user.set_complete
  end

  def game_over?
    games_users.pluck(:set_complete).all?(true)
  end

  def cards
    Card.includes(:starting_games_user).where(games_users: { game_id: id }).order(id: :asc)
  end


  def self.random_public_game
    Game.pregame.public_game.sample
  end

  def rendezousing_games_users
    GamesUser.where(game_id: id)
  end

  def unassociated_rendezousing_games_users
    rendezousing_games_users.where(users_game_name: nil).order(id: :asc)
  end


  # def users_game_names
  #   users.map(&:current_games_user_name).try(:compact)
  # end
  def self.all_users_game_names join_code
    GamesUser.includes(:game).where(games: { join_code: join_code }).map(&:users_game_name).try(:compact)
  end


  # end scoping methods
  def self.start_game join_code
    Game.find_by(join_code: join_code).try(:start_game)
  end

  def start_game
    return false unless pregame?  # return if game doesn't exist or simultaneous press race condition
    return false if games_users.map(&:users_game_name).compact.length < 2  # return if game doesn't exist or simultaneous press race condition

    update(status: 'midgame', join_code: nil)
    # remove user games_users association to people that didn't submit a name
    unassociated_rendezousing_games_users.destroy_all

    update( passing_order: user_ids.shuffle.to_s )
    true
  end


# ie
# [
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
#   [ [users_game_name, Card.create], [users_game_name, Card.create], [users_game_name, Card.create] ],
# ]
  def lobby_a_new_user user_id
    user = User.find_by(id: user_id)
    user_current_game = user.try(:current_game)
    if  user.blank? ||                        # player doesn't exist or
        user.current_games_user_name ||         # player already created a game name for a game lobbying with game
        user_current_game.try(:midgame?)  # c) player is currently in the middle of a game

      return false

    elsif user_current_game.try(:pregame?)
      # remove other game user that the user wishes to not be associated with any more
      user.current_games_user.try(:destroy)
    end

    self.users << user
    true
  end

  def commit_a_lobbyed_user user_id, users_game_name=''
    gu = GamesUser.find_by(user_id: user_id, game_id: id)
    return false if gu.blank? || status != 'pregame'
    gu.update(users_game_name: users_game_name);
  end

  # r5
  def remove_player user_id
    user = users.find_by(id: user_id)

    return false if (user.blank? || status != 'pregame')

    if users.count <= 1
      self.destroy
    else
      games_users.find_by(user_id: user_id, game_id: id).try(:destroy)
    end

    true
  end

# midgame public methods

  # r5_wip
  # called by games_controller when person first lands on game_page
  # this assigns a placeholder card to the user's games_user
  def create_initial_placeholder_if_one_does_not_exist current_user_id
    if Card.get_placeholder_card(current_user_id, self).blank? && User.find(current_user_id).current_starting_card.blank?
      card = Card.initialize_placeholder_card( current_user_id, (description_first ? 'description' : 'drawing') )
      gu = games_users.find_by(user_id: current_user_id)
      card.starting_games_user = gu
      card.save

      games_users.find_by(user_id: current_user_id).starting_card = card
      return card
    end
  end


  # 6 statuses possible
    # user drawing card
      # 1) with no placeholder waiting - uploading user gets waiting status, next user gets new card status if they want choose to use it
      # 2) with a placeholder waiting - uploading user gets new card, next user gets new card status if they want choose to use it
    # user creating description
      # 3) with no placeholder waiting - uploading user gets waiting status, next user gets new card status if they want choose to use it
      # 4) with a placeholder waiting - uploading user gets new card, next user gets new card status if they want choose to use it
    # user passing is now done and
    # 5) is waiting for friends to finish - aka status: finished
    # 6) all other players are already finished - aka gameover




  def get_status_for_users users_arr
    return false if pregame?

    broadcast_params = { statuses: [] }
    if postgame? || game_over?
      return ( { game_over: { redirect_url: games_path } } )
    end

    users_arr.each_with_index do |user, index|

      placeholder_card = Card.get_placeholder_card(user.id, self)

      _user_status_in_game = { attention_users: [user.id] }

      #  if the user is done or waiting for others to pass him a card
      if( placeholder_card.present?)
        _user_status_in_game[:user_status] = 'working_on_card'
      else
        player_is_finished = GamesUser.find_by(user_id: next_player_after(user.id), game_id: id).set_complete
        _user_status_in_game[:user_status] = player_is_finished ? 'finished' : 'waiting'
      end

      previous_card = placeholder_card.try(:parent_card)
      if previous_card.present?
        if previous_card.description?
          _user_status_in_game[:previous_card] = { medium: previous_card.medium, description_text: previous_card.description_text }
        else
          previous_card_drawing_url = rails_blob_path(previous_card.drawing, disposition: 'attachment')
          _user_status_in_game[:previous_card] = { medium: previous_card.medium, drawing_url: previous_card_drawing_url }
        end
      end
      broadcast_params[:statuses] << _user_status_in_game
    end

    return broadcast_params
  end

  def set_up_next_players_turn current_card
    next_player = next_player_after(current_card.uploader_id)
    starting_games_user = current_card.starting_games_user
    current_user_id = current_card.uploader_id
    cards = starting_games_user.cards


    if next_player.id == starting_games_user.user_id
      starting_games_user.update(set_complete: true)

      update(status: 'postgame') if game_over? # are any sets not completed?
    else
      create_subsequent_placeholder_for_next_player next_player.id, current_card.id
    end

    true
  end

    # working!!!
    def next_player_after user_id
      user_index = parse_passing_order.index(user_id)
      return User.none if user_index.nil?
      user_id_of_next_user = parse_passing_order[ (user_index + 1) % parse_passing_order.length ]
      return User.find_by( id: user_id_of_next_user )
    end
  protected

    # called indirectly by games_channel through 'set_up_next_players_turn' for to prepare for the next players turn
    def create_subsequent_placeholder_for_next_player next_player_id, prev_card_id
      prev_card = Card.find(prev_card_id)
      card = Card.initialize_placeholder_card( next_player_id, (prev_card.drawing? ? 'description' : 'drawing'), prev_card_id )

      card.starting_games_user = prev_card.starting_games_user

      return card.save
    end


    #     # working!!!
    # def prev_player_before user_id
    #   user_index = parse_passing_order.index(user_id)
    #   return User.none if user_index.nil?
    #   user_id_of_next_user = parse_passing_order[ (user_index - 1) % parse_passing_order.length ]
    #   return User.find_by( id: user_id_of_next_user )
    # end

      # working!!!
    def parse_passing_order
      return [] if passing_order.blank?
      JSON.parse(passing_order)
    end
end
