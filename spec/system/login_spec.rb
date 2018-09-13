require 'rails_helper'
require 'support/login'

RSpec.describe "On the Sessions Page", :type => :system do
  before :all do
    driven_by(:selenium)
  end

  include LoginHelper

  context "can read the game instuctions", js: true do
    it do
      visit root_path

      expect(current_path).to eq('/')
      page.execute_script("$('.instructions-container').popover('show')"); # simulate clicking on instructions
      expect(page).to have_content(/Like the game telephone/)
    end
  end


  describe "logged in via" do
    context "facebook", vcr: true,  js: true do
      it 'user can see facebook username' do
        login_with 'facebook'

        expect(page).to redirect_to rendezvous_choose_game_type_page_path
        # expect(page.current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('#user-name', text: /Facebook User/)
        all('#user-avatar').each {|img| img['src'] }
      end
    end

    context "twitter" do
      it 'user can see twitter username' do
        login_with 'twitter'

        sleep 1
        byebug
        # expect(page.current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('#user-name', text: /Twitter User/)
        all('#user-avatar').each {|img| img['src'] }
      end
    end
  end
end
