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

  def cards
    Card.includes(:starting_games_user).where(games_users: { game_id: id }).order(:id)
  end
  # being scoping methods
  def self.all_users_game_names join_code
    GamesUser.includes(:game).where(games: { join_code: join_code }).map(&:users_game_name)
  end

  def self.random_public_game
    Game.pregames.public_games.sample
  end

  def unassociated_rendezousing_games_users
    GamesUser.where(game_id: id, users_game_name: nil)
  end
  # end scoping methods

  # working!!!
  def parse_passing_order
    return [] if passing_order.blank?
    JSON.parse(passing_order)
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

  def commit_a_rendezvoused_user user_id, users_game_name=''
    gu = GamesUser.find_by(user_id: user_id, game_id: id)
    return false if gu.blank? || status != 'pregame'
    gu.update(users_game_name: users_game_name);
  end

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
      card.parse_and_save_uri_for_drawing upload_card_params
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

      if card.is_description?
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

        if card.is_description?
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
    card = create_placeholder_card( next_player_id, (prev_card.is_drawing? ? 'description' : 'drawing') )
    card.update(starting_games_user: prev_card.starting_games_user)

    return prev_card.child_card = card
  end



  # params a XOR b XOR c XOR d
  #  a) broadcast_params: { game_over: true }
  #  b) broadcast_params: { game_over: false, set_complete: true,  attention_users: current_user_id }
  #  c) broadcast_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, description_text: description_text} } }
  #  d) broadcast_params: { game_over: false, set_complete: false, attention_users: next_user_id, prev_card: {id: card_id, drawing_url: url} } }
  def send_out_broadcasts_to_players_after_card_upload broadcast_params
    ActionCable.server.broadcast("game_#{id}", broadcast_params )
  end

  # working!!!
  # find the earliest placeholder created for user
  def get_placeholder_card current_user_id
    Card.where(uploader_id: current_user_id, starting_games_user_id: games_users.ids, drawing_file_name: nil, description_text: nil).order(:id).try(:first) || Card.none
  end


# postgame public methods
  def cards_from_finished_game
    return [] unless status == 'postgame'

    # all cards associated with this games get
    starting_cards = Card.all_starting_cards.includes(idea_catalyst: :game).where(games: { join_code: join_code } )

    result = []

    starting_cards.each do |starting_card|
      card_set = []
      placeholder_card = starting_card

      loop do
        uploaders_gamesuser = GamesUser.find_by(user_id: placeholder_card.uploader_id, game_id: self.id)
        card_set << [ uploaders_gamesuser.users_game_name, placeholder_card ]
        placeholder_card = placeholder_card.child_card
        break if placeholder_card.nil?
      end

      result << card_set
    end
    result
  end

  protected

    # working!!!
    def create_placeholder_card uploader_id, drawing_or_description
      if drawing_or_description == 'description'
        return Card.create( drawing_or_description: "description",
                            uploader_id: uploader_id)
      else
        return Card.create( drawing_or_description: "drawing", uploader_id: uploader_id)
      end
    end

    # working!!!
    def next_player_after user_id
      user_index = parse_passing_order.index(user_id)
      return User.none if user_index.nil?
      user_id_of_next_user = parse_passing_order[ (user_index + 1) % parse_passing_order.length ]
      return User.find_by( id: user_id_of_next_user )
    end





    # upload_card_params :  a XOR b
      # a) { description_text: "Suicidal Penguin"}
      # b) { filename: file.filename,  data: file.data };
    # def create_new_card current_user, upload_card_params
    #   if !upload_card_params[:description_text].blank? # description
    #     # This is initial card
    #     return Card.create( drawing_or_description: "description",
    #                  description_text: upload_card_params[:description_text],
    #                  uploader_id: current_user.id)
    #   elsif !upload_card_params[:filename].blank? && !upload_card_params[:data].blank? # drawing
    #      card = Card.parse_uri_to_drawing_card(upload_card_params.slice(:filename, :data))
    #      card.update(uploader_id: current_user.id)
    #   else
    #     return Card.none
    #   end
    # end
end
