require 'rails_helper'
require 'support/login'

RSpec.describe "OutOfGameCardUploadController", type: :request do
  include LoginHelper::RequestTests

  describe "GET /out_of_game_card_upload_controller_spec.rb" do
    it "works! (now write some real specs)" do
      current_user = FactoryBot.create(:user);
      FactoryBot.create_list :card, 3, out_of_game_card_upload: true, uploader: current_user
      set_signed_cookies({user_id: current_user})

      get out_of_game_card_upload_controller_specs_path, params: { }
      byebug
      expect(response).to have_http_status(200)
    end
  end
end
