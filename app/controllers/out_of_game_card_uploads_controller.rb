class OutOfGameCardUploadsController < ApplicationController
  before_action :create_params, only: :create

  def new
  end


  def index
    respond_to do |format|
      format.js do
        # raise("I don't think this is ever called")
        # json = Card.get_desired_out_of_game_card_attributes(current_user)
        # render(json: json) and return
      end
      format.json do
        json = Card.get_desired_out_of_game_card_attributes(current_user)
        render(json: json) and return
      end
    end
  end

  def create
    begin
      create_params[:drawings].each do |drawing|
        Card.create(uploader_id: current_user.id, medium: 'drawing', drawing: drawing, out_of_game_card_upload: true)
      end
      flash[:notice] = %(Successfully Uploaded #{create_params[:drawings].length} #{'Image'.pluralize(create_params[:drawings].length)}. <a href=#{all_postgames_page_path}>View Uploaded Drawings</a> )
      redirect_to(action: :new) and return
    rescue => e
      flash[:alert] = "Upload Unsuccessful. #{e.full_message}"
      redirect_to(action: :new) and return
    end
  end

  protected
    def create_params
      params.require(:drawing).permit(drawings: [])
    end
end
