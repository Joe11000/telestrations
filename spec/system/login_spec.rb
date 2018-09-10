require 'rails_helper'
require 'support/login'

RSpec.describe "User lands on correct root page when", :type => :system do
  before :all do
    driven_by(:selenium)
  end

  include LoginHelper

  context "when they are not logged in" do
    it do
      visit root_path

      expect(current_path).to eq('/')
    end
  end

  describe "when they logged in via" do
    context "facebook", vcr: true,  js: true do
      it 'user can see facebook username' do
        byebug
        login_with 'facebook'

        expect(page).to have_css('.user-name', text: /Facebook User/)
        expect(page).to have_css('.user-avatar')
        # byebug
        click_on 'logout'
        # sleep 2
        # byebug
        expect(page.current_path).to '/'

      end
    end

    context "twitter" do
      it 'user can see twitter username' do
        byebug
        login_with 'twitter'
        expect(current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('.user-name', text: /Facebook User/)
        expect(page).to have_css('.user-avatar')

        click_on 'logout'
        expect(page.current_path).to '/'
      end
    end
  end
end
