class InGameCardUploadController < ApplicationController
  before_action :upload_files, only: :create

  def new
  end

  def create

  end



  protected
    def upload_files
      params.require('drawing')['drawings']
    end
end
