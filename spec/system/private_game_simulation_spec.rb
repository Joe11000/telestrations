require 'rails_helper'
require 'support/login'
require 'support/helpers'

RSpec.describe 'A User can' do
  include LoginHelper
  include Helpers

  xit 'logout' do
    in_browser(:facebook_user) do
      login_with 'facebook'
      click_button "Private"
    end

    in_browser(:twitter_user) do
      login_with 'twitter'
    end

  end
end
