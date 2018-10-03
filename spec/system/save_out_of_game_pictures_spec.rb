require 'rails_helper'

RSpec.describe 'A user can save out of game drawings', type: :system do
  xit '' do
    login_with 'twitter'

    find("[data-id='out-of-game-drawings-link']").click


  end
end

