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

    def form_login 
      visit root_path
      num_of_users = User.count + 1
      within '#login_form' do 
        fill_in :email, with: "Email_#{num_of_users}"
        fill_in :password_digest, with: "Password_#{num_of_users}"
        click_on 'Submit'
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
