source 'https://rubygems.org'

ruby '2.6.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
gem 'sprockets', '>= 3.7.2'
gem 'nokogiri', '>= 1.8.2'
gem 'rubyzip', '>= 1.2.2'
gem 'rails-html-sanitizer', '>= 1.0.4'
gem 'rack-protection', '>= 1.5.5'
gem 'loofah', '>= 2.2.1'
gem 'ffi', '>= 1.9.24'

# gem "rails", github: "rails/rails", ref: "dbf67b3a6f549769c5f581b70bc0c0d880d5d5d1"
# Use postgresql as the database for Active Record
gem 'pg'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'mini_racer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Puma as the app server
gem 'puma'

# Use Puma as the app server
# Use SCSS for stylesheets
gem 'sass-rails'

# Use ActiveModel has_secure_password
gem "font-awesome-rails"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call '' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_bot_rails'
  gem 'rspec-rails'

end
  gem 'faker'

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'foreman'
  # gem 'guard'
  # gem 'guard-rspec'
end

gem 'guard-rails', require: false

# # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'slim'
gem 'bootstrap', '~> 4.1.3'
# gem 'paperclip'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'redis'
# gem 'em-hiredis'
gem 'sidekiq'
gem 'sidetiq'
gem 'paranoia'


# Add support to use es6 based on top of babel, instead of using coffeescript
gem 'sprockets-es6'

# testing
group :test do
  # gem 'database_cleaner'
  gem 'selenium-webdriver'
  gem 'webmock'
  gem 'shoulda-matchers'

  gem 'capybara'
  # gem 'poltergeist'
  gem 'rack-test'
  # gem 'rails-controller-testing'
  gem 'chromedriver-helper'
  gem 'vcr', '< 4.0'
  gem 'tcr'
  gem 'action-cable-testing'
  gem 'database_cleaner'
  gem 'rails-controller-testing' # for testing games_controller
  gem 'rspec-json_expectations'
  gem 'simplecov', require: false
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen'
  gem 'travis'
  gem 'bullet'
  gem 'rails-erd'
end


# group :production do
#   gem 'rails_12factor'
# end


# Gems for revised project
gem 'aws-sdk-s3', require: false

# generate random words for user if they give up
# ie TokenPhrase.generate(' ', numbers: false)
gem 'token_phrase'
gem 'mini_magick'
gem 'rubocop'
gem 'webpacker'
# gem 'teaspoon-mocha', group: [:development, :test]
