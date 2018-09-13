require 'rails_helper'
require 'support/login'

RSpec.describe "User lands on correct root page when", :type => :system do
  before :all do
    driven_by(:selenium)
  end

  include LoginHelper

  context "not logged in" do
    xit do
      visit root_path

      expect(current_path).to eq('/')
    end
  end

  describe "logged in via" do
    before :each do
      # OmniAuth.config.mock_auth[:twitter] = nil
      # OmniAuth.config.mock_auth[:facebook] = nil

      # Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]

    end

    context "facebook", vcr: true,  js: true do
      xit 'user can see facebook username' do
        login_with 'facebook'

        expect(page.current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('#user-name', text: /Facebook User/)
        expect(page).to have_css('#user-avatar')
        # click_on 'logout'

      end
    end

    context "twitter" do
      fit 'user can see twitter username' do
        login_with 'twitter'
        expect(current_path).to eq '/auth/twitter'
        sleep 1
        byebug
        expect(page).to have_css('#user-name', text: /Twitter User/)
         all('#user-avatar').each {|img| img['src'] }
      end
    end
  end
end
