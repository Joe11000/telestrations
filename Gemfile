source 'https://rubygems.org'

ruby '2.5.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'

# gem "rails", github: "rails/rails", ref: "dbf67b3a6f549769c5f581b70bc0c0d880d5d5d1"
# Use postgresql as the database for Active Record
gem 'pg'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

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
gem 'bcrypt'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'factory_girl_rails'
  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'foreman'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'sass'
gem 'slim'
# gem "twitter-bootstrap-rails"
gem 'bootstrap'
gem 'paperclip'
gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'dotenv-rails'
gem 'redis'
gem 'em-hiredis'
gem 'sidekiq'
gem 'sidetiq'
gem 'tcr'
# gem "paperclip-dropbox", ">= 1.3.2"

# react-rails isn't compatible yet with latest Sprockets.
# https://github.com/reactjs/react-rails/pull/322
# gem 'react-rails'

# Add support to use es6 based on top of babel, instead of using coffeescript
gem 'sprockets-es6'

# testing
group :test do
  # gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'webmock'
  gem 'shoulda-matchers'

  gem 'capybara'
  gem 'poltergeist'
  gem 'rack-test'
  gem 'rails-controller-testing'
end


group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring-watcher-listen'
  gem 'travis'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# group :production do
#   gem 'rails_12factor'
# end

gem 'aws-sdk-s3'
