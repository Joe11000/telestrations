require 'rails_helper'
require 'support/login'

RSpec.describe "OutOfGameCardUploadController", type: :request do
  include LoginHelper::RequestTests

  xdescribe "GET /out_of_game_card_upload_controller_spec.rb" do
    it "works! (now write some real specs)" do
      get out_of_game_card_upload_controller_spec.rbs_path
      expect(response).to have_http_status(200)
    end
  end
end
