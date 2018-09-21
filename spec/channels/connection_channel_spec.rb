require 'rails_helper'

RSpec.describe ApplicationCable::ConnectionChannel, type: :channel do
  context 'testing connection authentication' do
    it "successfully connects" do
      user_id = FactoryBot.create(:user).id

      connect "/cable", cookies: { user_id: user_id }
      # connect "/cable", headers: { "X-USER-ID" => "325" }
      expect(connection.user_id).to eq user_id
    end

    it "rejects connection" do
      expect { connect "/cable" }.to have_rejected_connection
    end
  end
end
