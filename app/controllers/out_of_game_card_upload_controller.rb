class OutOfGameCardUploadController < ApplicationController
  before_action :create_params, only: :create

  def new

  end

  def index

  end

  def create
    begin
      create_params[:drawings].each do |drawing|
        Card.create(uploader_id: current_user.id, medium: 'drawing', idea_catalyst_id: current_user.id, drawing: drawing)
      end
      flash[:notice] = %(Successfully Uploaded #{create_params[:drawings].length} #{'Image'.pluralize(create_params[:drawings].length)}. <a href=#{all_postgames_page_path}>View Uploaded Drawings</a> )
      redirect_to(action: :new) and return
    rescue => e
      byebug
      flash[:alert] = "Upload Unsuccessful. #{e.full_message}"
      redirect_to(action: :new) and return
    end
  end

  protected
    def create_params
      params.require(:drawing).permit(drawings: [])
    end
end
