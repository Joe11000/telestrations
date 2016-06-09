class CardsController < ApplicationController
  def new
  end

  def create
  end

  def bulk_upload_page
  end

  def bulk_upload
    begin
      # f = File.new(upload_params.first, "r")
      byebug
      upload_params.each do |drawing_url|

        Card.create(uploader_id: current_user.id, drawing: drawing_url, drawing_or_description: 'drawing')
      end

      flash.now[:notice] = 'Upload Successful'
      render :bulk_upload_page and return
    rescue => e
      redirect_to bulk_upload_cards_page_path

      flash.now[:alert] = 'Upload Unsuccessful'
      render :bulk_upload_page and return
    end
    render nothing: true
  end

  protected
    def upload_params
      params.require('drawings')
    end
end
