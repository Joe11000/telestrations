require 'rails_helper'
require 'support/login'
require 'support/helpers'

RSpec.describe 'A User can' do
  include LoginHelper
  include Helpers

  it 'logout' do
    login_with 'facebook'
    click_button "logout"
    expect(page.current_path).to eq root_path
  end

  it 'see username' do

  end


  it 'see avatar picture'


  context 'get info on' do
    it 'private games' do
      login_with 'facebook'

      private_game_info_str = "This game type can only be joined if code is known."
      public_game_info_str = "This game type can be joined by either the join code or any player randomly joining a game."

      # no popovers visible at first
      expect(page).not_to have_content(Regex.new(private_game_info_str))
      expect(page).not_to have_content(Regex.new(public_game_info_str))

      # click public game popover and see info
      page.execute_script(%( $("[data-id='info-about-public-game']").popover('show'))); # simulate clicking on instructions
      expect(page).not_to have_content(Regex.new(private_game_info_str))
      expect(page).to have_content(Regex.new(public_game_info_str))

      # click private game popover and see info
      page.execute_script(%( $("[data-id='info-about-private-game']").popover('show'))); # simulate clicking on instructions
      expect(page).to have_content(Regex.new(private_game_info_str))
      expect(page).not_to have_content(Regex.new(public_game_info_str))
    end

    it 'public games'
  end

  context 'create a new' do
    context 'private game' do
      it 'has a game id' do
        login_with 'facebook'

        within '#private-game-option' do
          click_on "Private"
        end

        expect(page).to have_content?("Join This Private Game")
      end

      it 'has no one else in it' do
        login_with 'facebook'

        within '#private-game-option' do
          click_on "Private"
        end

        expect(page).to have_content?("Join This Private Game")
      end

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
