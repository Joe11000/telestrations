require 'rails_helper'
require 'support/login'

RSpec.describe "On the Sessions Page,", :type => :system do
  before :all do
    driven_by(:selenium_chrome_headless)
  end

  include LoginHelper::SystemTests

  context "user can read the game instuctions", :r5, :no_travis do
    it do
      visit root_path

      expect(current_path).to eq('/')

      page.execute_script("$('.instructions-container').popover('show')"); # simulate clicking on instructions
      expect(page).to have_content(/Like the game telephone/)
    end
  end


  describe "user logs in via", :r5 do
    it 'sees his user email on the next page' do
      user = form_login! 

      expect(page).to have_css('#user-email', text: user.email)
    end
  end
end
