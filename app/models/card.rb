class Card < ActiveRecord::Base
  # acts_as_paranoid

  belongs_to :idea_catalyst, class_name: 'GamesUser', inverse_of: :starting_card
  belongs_to :parent_card, class_name: 'Card', inverse_of: :child_card
  has_one :child_card, class_name: 'Card', foreign_key: :parent_card_id, inverse_of: :parent_card
  belongs_to :uploader, foreign_key: :uploader_id, class_name: 'User'

  has_attached_file :drawing, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :drawing, :content_type => /\Aimage\/.*\Z/
  validates :drawing_or_description, presence: true, inclusion: ['drawing', 'description']

  scope :all_starting_cards, -> { where.not(cards: { idea_catalyst_id: nil}) }

  scope :cards_independent_of_a_game, -> (user_id) { where(uploader_id: user_id, idea_catalyst_id: nil, parent_card_id: nil) }

  def is_description?
    drawing_or_description == 'description'
  end

  def is_drawing?
    drawing_or_description == 'drawing'
  end
end

# class Card < ActiveRecord::Base
#   # acts_as_paranoid

#   belongs_to :idea_catalyst, class_name: 'GamesUser', inverse_of: :starting_card
#   belongs_to :parent_card, class_name: 'Card', inverse_of: :child_card
#   has_one :child_card, class_name: 'Card', foreign_key: :parent_card_id, inverse_of: :parent_card
#   belongs_to :uploader, foreign_key: :uploader_id, class_name: 'User'

#   has_attached_file :drawing, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
#   validates_attachment_content_type :drawing, :content_type => /\Aimage\/.*\Z/


#   scope :all_starting_cards, -> { where.not(cards: { idea_catalyst_id: nil}) }

#   scope :all_unassociated_cards, -> { where(idea_catalyst_id: nil) }
# end


