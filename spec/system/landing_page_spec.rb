require 'rails_helper'

RSpec.describe "User lands on correct root page when", :type => :system do

  def login provider
    visit root_path

    case provider.downcase
      when 'facebook', 'twitter'
        find('#' + provider + '_logo').click
      end
  end

  context "when they are not logged in" do
    visit root_path

    expect(current_path).to eq '/'
  end

  describe "when they logged in as" do

    context "a User in facebook" do
      login 'facebook'

      expect(current_path).to eq new_game_path
    end

    context "a User in twitter" do
      login 'twitter'

      expect(current_path).to eq new_game_path
    end
  end
end
