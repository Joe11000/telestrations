class OutOfGameCardUploadsController < ApplicationController
  before_action :create_params, only: :create

  def new
  end


  def index

    # json = Card.get_desired_out_of_game_card_attributes(current_user)
    # render(json: json) and return
  end

  def create
    cards_to_upload = create_params[:drawings].respond_to?(:each) ? create_params[:drawings] : [ create_params[:drawings] ]
    
    begin
      cards_to_upload.each do |drawing|
        Card.create(uploader_id: current_user.id, medium: 'drawing', drawing: drawing, out_of_game_card_upload: true)
      end
      flash[:notice] = %(Successfully Uploaded #{cards_to_upload.length} #{'Image'.pluralize(cards_to_upload.length)})
      redirect_to(action: :new) and return
    rescue => e
      flash[:alert] = "Upload Unsuccessful. #{e.full_message}"
      redirect_to(action: :new) and return
    end
  end

  protected
    def create_params
      params.permit(:drawings, drawings: [])
    end
end
