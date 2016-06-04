
class Card < ActiveRecord::Base
  # acts_as_paranoid

  belongs_to :idea_catalyst, class_name: 'GamesUser', inverse_of: :starting_card # signifies this card is a starting card. Because trying to find all starting cards was harder before doing this
  belongs_to :parent_card, class_name: 'Card', inverse_of: :child_card
  belongs_to :starting_games_user, class_name: 'GamesUser'
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

  # def fill_in_info_for_placeholder_card id,
#
  # end

  # ( {filename: '', data: ''}) # data is the uri
  def parse_and_save_uri_for_drawing paperclip_card_params
    # Instantiates Paperclip::DataUriAdapter attachment
    file = Paperclip.io_adapters.for(paperclip_card_params[:data])
    file.original_filename = paperclip_card_params[:filename]

    self.update(drawing: file)
  end

  protected

end
