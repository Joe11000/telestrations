# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require "action_cable/testing/rspec"
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!


# OmniAuth
OmniAuth.config.test_mode = true
Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:twitter]
OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
  provider: 'twitter',
  uid: '222222',
  info: {
    name: "Twitter User",
    image: "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg"
  }
  # etc.
})
OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
  provider: 'facebook',
  uid: '111111',
  info: {
    name: "Facebook User",
    image: "http://joe-noonan-101.herokuapp.com/assets/formal_me/1-00e70838635a49004071492dcfe4e154600e684f8f3e81899ac265286c7fd685.jpg"
  }
  # etc.
})



RSpec.configure do |config|

  config.include Rails.application.routes.url_helpers

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  [:controller, :view, :request].each do |type|
    config.include ::Rails::Controller::Testing::TestProcess, :type => type
    config.include ::Rails::Controller::Testing::TemplateAssertions, :type => type
    config.include ::Rails::Controller::Testing::Integration, :type => type
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    # with.library :active_record
    # with.library :active_model
    # with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end




require 'rubygems'
# require 'test/unit'
require 'vcr'

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<twitter_api_key>') { Rails.application.credentials.dig(:twitter, :api_key) }
  config.filter_sensitive_data('<facebook_api_key>') { Rails.application.credentials.dig(:facebook, :api_key) }
end




# default
# RSpec.configure do |config|
#
#   config.before(:suite) do
#     DatabaseCleaner.strategy = :transaction
#     DatabaseCleaner.clean_with(:truncation)
#   end

#   config.around(:each) do |example|
#     DatabaseCleaner.cleaning do |a|
#       example.run
#     end
#   end

# end
RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:all) do
    # Clean before each example group if clean_as_group is set
    if self.class.metadata[:clean_as_group]
      DatabaseCleaner.clean
    end
  end

  config.after(:all) do
    # Clean after each example group if clean_as_group is set
    if self.class.metadata[:clean_as_group]
      DatabaseCleaner.clean
    end
  end

  config.before(:each) do
    # Clean before each example unless clean_as_group is set
    unless self.class.metadata[:clean_as_group]
      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    # Clean before each example unless clean_as_group is set
    unless self.class.metadata[:clean_as_group]
      DatabaseCleaner.clean
    end
  end

end
