require 'rails_helper'
require 'support/login'

RSpec.describe "OutOfGameCardUploadController", type: :request do
  include LoginHelper::RequestTests

  describe "GET /out_of_game_card_upload_controller_spec.rb" do
    # it "works! (now write some real specs)" do
    #   current_user = FactoryBot.create(:user);
    #   FactoryBot.create_list :card, 3, out_of_game_card_upload: true, uploader: current_user
    #   set_signed_cookies({user_id: current_user})

    #   get out_of_game_card_upload_controller_specs_path, params: { }
    #   byebug
    #   expect(response).to have_http_status(200)
    # end

    it "should return expected return values for desired component (I know this should be in a controller test testing a controller/get_desired_out_of_game_card_attributes.rb mixin, but bad design planning to fix for later.)", :r5_now do 
      FactoryBot.create(:pregame, callback_wanted: :pregame)
      game = FactoryBot.create(:postgame, callback_wanted: :postgame)
      current_user = game.users.first
      out_of_game_card_uploads = FactoryBot.create_list :drawing, 3, uploader: current_user, out_of_game_card_upload: true
      out_of_game_card_uploads = out_of_game_card_uploads.reverse # the result will be ordered by most recent

      set_signed_cookies({user_id: current_user.id})

      whitelist_attributes = [:description_text, :id, :idea_catalyst_id, :medium, :out_of_game_card_upload, :parent_card_id, :placeholder, :starting_games_user_id, :uploader_id]; # drawing_url is tested seperately

      get out_of_game_card_uploads_path, params: {}, xhr: true

      JSON.parse(response.body)[0].each_with_index do |gu, i| # [0] gets through the 
        expect(gu[0]).to eq ''
        
        whitelist_json = out_of_game_card_uploads[i].slice(whitelist_attributes)
        expect(gu[1]).to include_json whitelist_json
        expect(gu[1]['drawing_url']).to be_a String
        expect(gu[1]['drawing_url'].length).to be > 10
      end
    end
  end
end
