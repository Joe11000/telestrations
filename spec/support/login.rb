module LoginHelper
  # def stub_omni_auth provider
  #   case provider.downcase
  #   when 'facebook'
  #     OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
  #       provider: 'facebook',
  #       uid: '111111',
  #       name: "Facebook User",
  #       provider_avatar: "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg"
  #       # etc.
  #     })
  #   when 'twitter'
  #     OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
  #       provider: 'twitter',
  #       uid: '222222',
  #       name: "Twitter User",
  #       provider_avatar: "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg"
  #       # etc.
  #     })
  #   end
  # end

  def login_with provider
    # stub_omni_auth provider

    visit root_path

    case provider.downcase
    when 'facebook', 'twitter'
      VCR.use_cassette("#{provider.downcase}_user_info", record: :new_episodes) do
        find('#' + provider + '_logo').click
      end
    end
  end
end
