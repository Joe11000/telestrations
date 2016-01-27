require 'spec_helper'
require 'rails_helper'

RSpec.feature "User lands on correct root page when", :type => :feature do

  def login provider
    visit root_path

    case provider.downcase
      when 'anonymous'
        click_link('Let Me Play Anonymously')
      when 'twitter'
      when 'facebook'
        find(provider + '_logo').click
      end
  end

  scenario "when they are not logged in" do
    visit root_path

    expect(current_path).to eq '/'
  end

  describe "when they logged in as" do

    scenario "a User in facebook" do
      login twitter

      expect(current_path).to eq '/'
    end

    scenario "a User in twitter" do
      login twitter

      expect(current_path).to eq '/'
    end

    scenario "Anonymous" do
      login anonymous


    end
  end
end
