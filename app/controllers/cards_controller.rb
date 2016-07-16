class CardsController < ApplicationController
  def new
  end

  def create
  end

  def bulk_upload_page
  end

  def bulk_upload
    begin
      upload_files.each do |drawing|
        Card.create(uploader_id: current_user.id, drawing: drawing, drawing_or_description: 'drawing')
      end

      flash.now[:notice] = 'Upload Successful'
      render :bulk_upload_page and return
    rescue => e
      redirect_to bulk_upload_cards_page_url

      flash.now[:alert] = 'Upload Unsuccessful'
      render :bulk_upload_page and return
    end
    render nothing: true
  end

  protected
    def upload_files
      params.require('drawing')['avatar']
    end
end
