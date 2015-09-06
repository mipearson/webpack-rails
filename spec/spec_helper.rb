require "rspec"
require "rails"
require "webpack/rails"
require 'webmock/rspec'

module Dummy
  class Application < Rails::Application
    config.eager_load = false
  end
end

Rails.application.initialize!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
