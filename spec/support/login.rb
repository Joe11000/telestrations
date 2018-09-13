module LoginHelper
  def login_with provider
    visit root_path

    case provider.downcase
    when 'facebook', 'twitter'
      VCR.use_cassette("support/vcr_cassettes/#{provider.downcase}_user_info", record: :new_episodes) do
        find('#' + provider + '_logo').click
      end
    end
  end
end
