module LoginHelper
  module SystemTests
    def in_browser(name)
      old_session = Capybara.session_name

      Capybara.session_name = name
      yield

      Capybara.session_name = old_session
    end

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

  module RequestTests
    def set_signed_cookies params={}
      signed_cookies = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar

      params.each do |key, value|
        signed_cookies.signed[key.to_sym] = value
        cookies[key.to_sym] = signed_cookies[key.to_sym]
      end

      cookies
    end
  end
end
