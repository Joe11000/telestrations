OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Rails.env.test?

  provider :twitter, \
           Rails.application.credentials.dig( :twitter, :key), \
           Rails.application.credentials.dig( :twitter, :secret) do
            { \
              secure_image_url: 'true', \
              image_size: 'original' \
            }
  end
end


Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, \
         Rails.application.credentials.dig(:facebook, :key), \
           Rails.application.credentials.dig(:facebook, :secret)
end
