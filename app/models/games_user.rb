class GamesUser < ActiveRecord::Base
  # acts_as_paranoid

  belongs_to :user
  belongs_to :game

  has_one :starting_card, class_name: 'Card',
                          foreign_key: :idea_catalyst_id
end
