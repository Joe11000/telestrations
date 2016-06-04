class GamesUser < ActiveRecord::Base
  # acts_as_paranoid

  belongs_to :user
  belongs_to :game

  has_one :starting_card, class_name: 'Card',
                          foreign_key: :idea_catalyst_id

  # working !!!
  def cards
    Card.where(starting_games_user_id: id).order(:id)
  end
end
