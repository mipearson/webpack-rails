require 'rails'
require 'rails/railtie'
require 'webpack/rails/react/helper'

module Webpack
  # :nodoc:
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      ActiveSupport.on_load(:action_view) do
        include Webpack::Rails::React::Helper
      end
    end

    config.webpack = ActiveSupport::OrderedOptions.new
    config.webpack.config_file = 'config/webpack.config.js'
    config.webpack.binary = 'node_modules/.bin/webpack'

    config.webpack.dev_server = ActiveSupport::OrderedOptions.new
    config.webpack.dev_server.host = 'localhost'
    config.webpack.dev_server.port = 3808
    config.webpack.dev_server.https = false # note - this will use OpenSSL::SSL::VERIFY_NONE
    config.webpack.dev_server.binary = 'node_modules/.bin/webpack-dev-server'
    config.webpack.dev_server.enabled = !::Rails.env.production?

    config.webpack.output_dir = "public/webpack"
    config.webpack.public_path = "webpack"
    config.webpack.manifest_filename = "manifest.json"

    rake_tasks do
      load "tasks/webpack.rake"
    end
  end
end
