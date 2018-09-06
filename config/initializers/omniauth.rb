Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :twitter, Rails.application.credentials.dig(Rails.env.to_sym, :twitter, :key), Rails.application.credentials.dig(Rails.env.to_sym, :twitter, :secret) do
    {
      secure_image_url: 'true',
      image_size: 'original'
    }
  end

  provider :facebook, Rails.application.credentials.dig(Rails.env.to_sym, :facebook, :key), Rails.application.credentials.dig(Rails.env.to_sym, :facebook, :secret)
end
