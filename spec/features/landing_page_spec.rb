require 'rails_helper'

RSpec.describe 'can see landing page', type: :feature do 
  it 'can see the landing page' do 
    visit root_path

    expect(page.current_path).to eq root_path
  end



end