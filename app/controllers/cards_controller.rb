class CardsController < ApplicationController
  def new
  end

  def create
  end

  def upload_page
    @card = Card.new
  end

  def upload
    byebug
    upload_params
    # <%= file_field_tag :avatar, multiple: true %>

  end

  protected
    def upload_params
      # params.require('card')
    end
end
