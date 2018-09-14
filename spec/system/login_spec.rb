require 'rails_helper'
require 'support/login'

RSpec.describe "On the Sessions Page,", :type => :system do
  before :all do
    driven_by(:selenium_chrome_headless)
  end

  include LoginHelper

  context "user can read the game instuctions", r5: true do
    it do
      visit root_path

      expect(current_path).to eq('/')
      page.execute_script("$('.instructions-container').popover('show')"); # simulate clicking on instructions
      expect(page).to have_content(/Like the game telephone/)
    end
  end


  describe "user logs in via", r5: true do
    context "facebook" do
      it 'sees his facebook username on the next page' do
        login_with 'facebook'

        expect(page).to have_css('#user-name', text: /Facebook User/)
        # all('#user-avatar').each {|img| img['src'] == User.last.provider_avatar}
        expect(User.last.provider_avatar.attached?).to eq true
      end
    end

    context "twitter" do
      it 'sees his twitter info on the next page' do
        login_with 'twitter'

        expect(page).to have_css('#user-name', text: /Twitter User/)
        all('#user-avatar').each {|img| img['src'] }
        expect(User.last.provider_avatar.attached?).to eq true
      end
    end
  end
end
