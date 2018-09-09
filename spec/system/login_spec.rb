require 'rails_helper'
require 'support/login'

RSpec.describe "User lands on correct root page when", :type => :system do
  before :all do
    driven_by(:selenium)
  end

  include Login

  context "when they are not logged in" do
    it do
      visit root_path

      expect(current_path).to eq('/')
    end
  end

  describe "when they logged in via" do
    context "facebook", vcr: true,  js: true do
      it 'user can see facebook username' do
        login_with 'facebook'

        expect(current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('.user-name', text: /Joe Noonan/)
        expect(page).to have_css('.user-avatar')
      end
    end

    context "twitter" do
      fit 'user can see twitter username' do
        login_with 'twitter'

        expect(current_path).to eq rendezvous_choose_game_type_page_path
        expect(page).to have_css('.user-name', text: /Joe Noonan/)
        expect(page).to have_css('.user-avatar')
      end
    end
  end
end
