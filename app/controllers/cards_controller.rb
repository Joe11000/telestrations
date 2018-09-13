class CardsController < ApplicationController
  before_action :upload_files, only: [:out_of_game_upload, :in_game_upload]

  def in_game_upload

  end

  def out_of_game_upload_page
  end

  def out_of_game_upload
    begin
      upload_files.each do |drawing|
        Card.create(uploader_id: current_user.id, drawing: drawing, type: 'drawing')
      end

      flash.now[:notice] = 'Upload Successful'
      render :out_of_game_upload and return
    rescue => e
      flash.now[:alert] = 'Upload Unsuccessful'
      render :out_of_game_upload and return
    end
  end

  protected
    def upload_files
      params.require('drawing')['avatar']
    end
end
