require 'rails_helper'
require 'support/login'
RSpec.describe 'upload_out_of_game_cards_spec', type: :system do 
  include LoginHelper::SystemTests

  before :all do
    driven_by(:selenium_chrome)
  end

  describe 'no out of game cards uploaded by user' do 
    before :all do 
      form_login! 
      expect(page.current_path).to eq choose_game_type_page_path
      
      visit games_path
    end
    
    it 'returns a valid text', focus: true do
      expect(page).to have_css '#out_of_game_card_upload_tab'
      click_link 'out_of_game_card_upload_tab'
      expect(page).to have_content "You don't have any images uploaded out of game"
    end
  end

  describe 'upload one drawing file' do 
    before :each do 
      form_login! 
      expect(page.current_path).to eq choose_game_type_page_path
      
      visit new_out_of_game_card_upload_path
      expect(page.current_path).to eq new_out_of_game_card_upload_path
      file_path = File.join(Rails.root, file_fixture('images/Ace_of_Diamonds.jpg'))

      within '#file_upload_form' do 
        attach_file 'drawings', file_path
        click_on 'Upload'
      end
    end
    
    it 'returns a valid text' do
      expect(page).to have_content(/Successfully Uploaded 1 Image/)  
    end
    
    it 'appears in the out_of_game_card_upload tab of the post_games page', :r5_wip do
      byebug
      click_link 'View Uploaded Drawings'
      expect(page).to have_css '#out_of_game_card_upload_tab'
      click_link 'out_of_game_card_upload_tab'
      byebug
      expect(page).to have_no_content "You don't have any images uploaded out of game"
    end
  end

  describe 'upload multiple files' do 
    before :all do 
      form_login! 
      byebug
      expect(page.current_path).to eq choose_game_type_page_path
      
      visit new_out_of_game_card_upload_path
      expect(page.current_path).to eq new_out_of_game_card_upload_path
      file_path = File.join(Rails.root, file_fixture('images/Ace_of_Diamonds.jpg'))
      file_path_2 = File.join(Rails.root, file_fixture('images/Ace_of_Spades.jpg'))

      within '#file_upload_form' do 
        attach_file 'drawings', [file_path, file_path_2 ]
        click_on 'Upload'
      end
    end
    
    it '' do
      expect(page).to have_content(/Successfully Uploaded 2 Images/)        
    end
  end
end