require 'spec_helper'
require 'rails_helper'

RSpec.feature "User lands on correct root page when", :type => :feature do

  def login provider
    visit root_path

    case provider.downcase
      when 'facebook', 'twitter'
        find('#' + provider + '_logo').click
      end
  end

  scenario "when they are not logged in" do
    visit root_path

    expect(current_path).to eq '/'
  end

  describe "when they logged in as" do

    scenario "a User in facebook" do
      login 'facebook'

      expect(current_path).to eq new_game_path
    end

    scenario "a User in twitter" do
      login 'twitter'

      expect(current_path).to eq new_game_path
    end
  end
end
