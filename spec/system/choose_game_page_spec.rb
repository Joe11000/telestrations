require 'rails_helper'
require 'support/login'
require 'support/helpers'

RSpec.describe 'A User can' do
  include LoginHelper
  include Helpers

  it 'logout' do
    in_browser(:facebook_user) do
      login_with 'facebook'
      click_on "Private"
      fill_in
    end

    in_browser(:twitter_user) do
      login_with 'twitter'
    end

  end

  it 'see username'


  it 'see avatar picture'


  context 'get info on' do
    it 'private games' do
      login_with 'facebook'

      click_on "Private"
      expect(page).to have_content?("Join This Private Game")
    end

    it 'public games'
  end

  context 'create a new' do
    context 'private game' do
      it 'has a game id' do

      end

      it 'has no one else in it'

    end

    context 'public game' do

    end
  end

  context 'Join a specific' do
    context 'private game' do
      it ''
    end

    context 'public game' do

    end
  end

  context 'Join a random' do
    context 'public game' do

    end
  end

  it 'visit page to upload multiple cards'
end
