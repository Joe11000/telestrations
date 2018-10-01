require 'rails_helper'
require 'support/login'
require 'support/helpers'

RSpec.describe 'LobbyChannelJsTestingSpec', type: :system do
  include LoginHelper
  include Helpers

  before :all do
    driven_by(:selenium_chrome)
    # driven_by(:selenium_chrome_headless)
  end

  context '2 can see each other log in and out on the lobby page'  do
    context 'first player private game, second player joins via join_code' do
      # it_behaves_like 'user 1 is on lobby page and sees other player come in, sign in, and then leave'


      it 'both players see the numbers associated with # of players joining and leaving game', :r5_wip do
        # user 1 is factboook_user and waits on lobby page
        in_browser(:user_1) do
          login_with 'facebook'
          click_button "Private"
          # byebug
          sleep 1
          byebug
          @join_code = find(".lobby-join-code").text
          expect(page).to have_content(/Users Not Joined \( 1 \)/) # incase of multiple instances on the page
          # expect(page).to have_content(/Users Not Joined/, minimum: 1, maximum: 1) # incase of multiple instances on the page
          # byebug
          expect(page).to have_content(/Users Joined \( 0 \)/) # incase of multiple instances on the page
          # expect(page).to have_content(/Users Joined/, minimum: 1, maximum: 1) # incase of multiple instances on the page
        end

        # user 2 joins game with user_1 in it and sees update
        in_browser(:user_2) do
          login_with 'twitter'
          # within "[data-id='join-code-submit-group']" do
            fill_in 'join_code', with: @join_code
            click_on 'Join Game'
            byebug
            click_button 'Join Game'
            # find('') 'Join Game'

          # end



          byebug
          visit lobby_path('private')

          byebug
          expect(page.current_path).to eq lobby_path('private')
          expect(page).to have_content(/Users Not Joined \( 2 \)/) # incase of multiple instances on the page
          expect(page).to have_content(/Users Joined \( 0 \)/) # incase of multiple instances on the page
        end

        # user 1 also sees the update from user_2 joining lobby page
        in_browser(:user_1) do
          expect(page).to have_content(/Users Not Joined \( 2 \)/) # incase of multiple instances on the page
          expect(page).to have_content(/Users Joined \( 0 \)/) # incase of multiple instances on the page
        end

        in_browser(:user_2) do
          fill_in 'name', with: 'user_2'
          click_button 'Join!'
          expect(page).to have_content(/Users Not Joined \( 1 \)/) # incase of multiple instances on the page
          expect(page).to have_content(/Users Joined \( 1 \)/) # incase of multiple instances on the page
        end

        # user 2 joins game with user_1 in it and sees update
        in_browser(:user_1) do
          expect(page).to have_content(/Users Not Joined \( 1 \)/) # incase of multiple instances on the page
          expect(page).to have_content(/Users Joined \( 1 \)/) # incase of multiple instances on the page
        end

        # user 2 bails on the game
        in_browser(:user_2) do
          click_link 'Leave Group'
          expect(page.current_path).to eq choose_game_type_page_path
        end

          # user 2 joins game with user_1 in it and sees update
        in_browser(:user_1) do
          expect(page).to have_content(/Users Not Joined \( 1 \)/) # incase of multiple instances on the page
          expect(page).to have_content(/Users Joined \( 0 \)/) # incase of multiple instances on the page
          click_link 'Leave Group'
          expect(page.current_path).to eq choose_game_type_page_path
        end
      end
    end
    context 'first player public game, second player joins via join_code'
    context 'first player random public game, second player joins via join_code'
    context 'first player random public game, second player joins via random public game'

  end
end
