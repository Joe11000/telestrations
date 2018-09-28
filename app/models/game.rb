class Game < ActiveRecord::Base
  has_many :games_users, ->{ order(id: :asc) }, inverse_of: :game, dependent: :destroy
  has_many :users, ->{ order(id: :asc) }, through: :games_users
  has_many :starting_cards, ->{ order(id: :asc) }, through: :games_users

  validates :join_code, uniqueness: true, length: { is: 4 }, if: Proc.new { !join_code.blank? }

  enum status: %w( pregame midgame postgame )
  enum game_type: %w( public private ), _suffix: :game

  after_find do
    # self.touch # remember activity for deleting if inactive later
  end

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

  # working!!!
  def parse_passing_order
    return [] if passing_order.blank?
    JSON.parse(passing_order)
  end


  def self.start_game join_code
    Game.find_by(join_code: join_code).try(:start_game)
  end

  def start_game
    raise "Game status must be pregame" unless pregame?  # return if game doesn't exist or simultaneous press race condition
    raise "Must have at least 2 players to start a game" if games_user_ids.length < 2  # return if game doesn't exist or simultaneous press race condition

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
  def rendezvous_a_new_user user_id
    user = User.find_by(id: user_id)
    user_current_game = user.try(:current_game)
    if  user.blank? ||                        # player doesn't exist or
        user.current_games_user_name ||         # player already created a game name for a game rendezvousing with game
        user_current_game.try(:midgame?)  # c) player is currently in the middle of a game

      return false

    elsif user_current_game.try(:pregame?)
      # remove other game user that the user wishes to not be associated with any more
      user.current_games_user.destroy
    end

    self.users << user
    true
  end

  # test right now
  def commit_a_rendezvoused_user user_id, users_game_name=''
    gu = GamesUser.find_by(user_id: user_id, game_id: id)
    return false if gu.blank? || status != 'pregame'
    gu.update(users_game_name: users_game_name);
  end

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

  # working!!!
  # called by games_controller when person first lands on game_page
  # this assigns a placeholder card to the user's games_user
  def create_initial_placeholder_for_user current_user_id
    card = create_placeholder_card( current_user_id, (description_first ? 'description' : 'drawing') )
    gu = games_users.find_by(user_id: current_user_id)
    card.update(starting_games_user: gu)
    games_users.find_by(user_id: current_user_id).starting_card = card
  end

  # working!!!
  # params :  a XOR b
    # a) upload_card_params: { 'description_text' => "Suicidal Penguin"}
    # b) upload_card_params: { 'filename' => file.filename,  data: file.data };
  def upload_info_into_existing_card current_user_id, upload_card_params
    current_user = users.find_by(id: current_user_id)
    card = get_placeholder_card current_user_id


    return false if current_user.blank? || card.blank?
    if upload_card_params.keys.include? 'description_text'
      card.update(description_text: upload_card_params['description_text'])
      return card
    else
      card.drawing.attach upload_card_params
      # card.parse_and_save_uri_for_drawing upload_card_params
      return card
    end
  end

  # wip
  def set_up_next_players_turn current_card_id
    card = Card.find(current_card_id)
    next_player = next_player_after(card.uploader_id)
    gu = card.starting_games_user
    current_user_id = card.uploader_id
    next_player_message_params = []

    if next_player.id == gu.user_id
      gu.update(set_complete: true)

      if gu.game.games_users.pluck(:set_complete).all? # are any sets not completed?
        # game is done
          update(status: 'postgame')
          return [ { game_over: true } ]
      else
        # game is not done. games_user set is done
          return [ { game_over: false, attention_users: card.uploader_id, set_complete: true } ]
      end

    else
      create_subsequent_placeholder_for_next_player next_player.id, card.id
      next_player_message_params = { game_over: false, set_complete: false, attention_users: next_player.id }

      if card.description?
        next_player_message_params.merge!({ prev_card: {id: card.id, description_text: card.description_text} })
      else
        next_player_message_params.merge!({ prev_card: {id: card.id, drawing_url: card.drawing.url} })
      end
    end


      current_player_message_params = {}
      # check if user that just submitted a card has one waiting for him
      existing_placeholder_for_uploading_user = get_placeholder_card current_user_id

      unless existing_placeholder_for_uploading_user.blank?
        current_player_message_params = { game_over: false, set_complete: false, attention_users: current_user_id }

        if card.description?
          current_player_message_params.merge!({ prev_card: {id: existing_placeholder_for_uploading_user.parent_card.id, description_text: existing_placeholder_for_uploading_user.parent_card.description_text} })
        else
          current_player_message_params.merge!({ prev_card: {id: existing_placeholder_for_uploading_user.parent_card.id, drawing_url: existing_placeholder_for_uploading_user.parent_card.drawing.url} })
        end
      end

     return current_player_message_params.blank? ? [ next_player_message_params ] : [ next_player_message_params, current_player_message_params ]
  end

  # called indirectly by games_channel through 'set_up_next_players_turn' for to prepare for the next players turn
  # working!!!
  def create_subsequent_placeholder_for_next_player next_player_id, prev_card_id
    prev_card = Card.find(prev_card_id)
    card = create_placeholder_card( next_player_id, (prev_card.drawing? ? 'description' : 'drawing') )
    card.update(starting_games_user: prev_card.starting_games_user)

    return prev_card.child_card = card
  end



  # params a XOR b XOR c XOR d
  #  a) broadcast_params: [ { game_over: true } ]
  #  b) broadcast_params: [ { game_over: false, set_complete: true,  attention_users: current_user_id } ]
  #  c) broadcast_params: [ { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, description_text: description_text} } }, { optional_message_to_self_about_waiting_placeholder_card } ]
  #  d) broadcast_params: [ { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, drawing_url: url} } }, { optional_message_to_self_about_waiting_placeholder_card } ]
  def send_out_broadcasts_to_players_after_card_upload broadcast_params_array
    broadcast_params_array.each do |broadcast_params|
      ActionCable.server.broadcast("game_#{id}", broadcast_params )
    end
  end

  # r5 tested
  # find the earliest placeholder created for user
  def get_placeholder_card current_user_id
    # if description placeholder
    result = Card.where(uploader_id: current_user_id, starting_games_user_id: games_users.ids).where(medium: 'description', description_text: nil).order(id: :asc).try(:last)
    return result unless result.blank?

    # if drawing placeholder
    result = Card.with_attached_drawing.where(uploader_id: current_user_id, starting_games_user_id: games_users.ids).where(medium: :drawing).order(id: :asc).select{|card| !card.drawing.attached?}.try(:last)
    return result unless result.blank?

    return nil
  end

  # r5 tested
  # postgame public methods
  def cards_from_finished_game
    return [] unless status == 'postgame'

    result = []
    games_users.each do |gu|
      gu_set = []
      card = gu.starting_card

      until card.blank? do
        gu_set << [ GamesUser.find_by(game_id: id, user_id: card.uploader).users_game_name, card ]
        card = card.child_card
      end

       result << gu_set
    end

    result
  end

  protected

    # working!!!
    def create_placeholder_card uploader_id, medium
      if medium == 'description'
        return Card.create( medium: "description",
                            uploader_id: uploader_id)
      else
        return Card.create( medium: "drawing", uploader_id: uploader_id)
      end
    end

    # working!!!
    def next_player_after user_id
      user_index = parse_passing_order.index(user_id)
      return User.none if user_index.nil?
      user_id_of_next_user = parse_passing_order[ (user_index + 1) % parse_passing_order.length ]
      return User.find_by( id: user_id_of_next_user )
    end
end
