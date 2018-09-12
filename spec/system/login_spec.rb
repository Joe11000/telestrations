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
        sleep 2
        byebug
        expect(page).to have_css('#user-name', text: /Twitter User/)
        expect(page).to have_css('#user-avatar')
        expect(page).to evaluate_script(%( document.querySelectorAll("[data-id='user-avatar']").attribute('src')  ))
        expect(scr).to eq "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg"

        # click_on 'logout'
      end
    end
  end
end
