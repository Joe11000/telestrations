source 'https://rubygems.org'

ruby '2.3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 5.0.0.beta4', '< 5.1'

# gem "rails", github: "rails/rails", ref: "dbf67b3a6f549769c5f581b70bc0c0d880d5d5d1"
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.x'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.0'


# Use Puma as the app server
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails', '4.5.0'
  gem 'faker', '1.6.1'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'foreman'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'sass', '3.2.19'
gem 'slim', '3.0.6'
gem "twitter-bootstrap-rails"
gem 'paperclip', '4.3.2'
gem 'omniauth-twitter', '1.2.1'
gem 'omniauth-facebook', '1.4.0'
gem 'dotenv-rails', '2.1.0'
gem 'paranoia', '1.2.0'
gem 'redis', '3.2.2'
gem 'em-hiredis'
gem 'sidekiq'
gem 'sidetiq'
gem 'tcr'
gem "paperclip-dropbox", ">= 1.3.2"

# react-rails isn't compatible yet with latest Sprockets.
# https://github.com/reactjs/react-rails/pull/322
# gem 'react-rails'

# Add support to use es6 based on top of babel, instead of using coffeescript
gem 'sprockets-es6'

# testing
group :test do
  gem 'database_cleaner', '1.5.1'
  gem 'rspec-rails', '3.1.0'
  gem 'selenium-webdriver', '2.49.0'
  gem 'webmock', '1.22.6'
  gem 'shoulda-matchers'

  gem 'capybara', '2.6.0'
  gem 'poltergeist', '1.8.1'
  gem 'rack-test'
  gem 'rails-controller-testing'
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'travis', '~> 1.8', '>= 1.8.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :production do
  gem 'rails_12factor'
end
