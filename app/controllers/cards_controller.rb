class CardsController < ApplicationController
  def new
  end

  def create
  end

  def upload_page
  end

  def upload
    begin
      # f = File.new(upload_params.first, "r")
      upload_params.each do |drawing_url|
        Card.create(uploader_id: current_user.id, drawing: drawing_url)
      end

      render :upload_page, notice: 'Upload Successful' and return
    rescue => e
      render :upload_page, alert: 'Upload Unsuccessful' and return
    end
  end

  protected
    def upload_params
      params.require('drawings')
    end
end
