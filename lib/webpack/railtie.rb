require 'rails'
require 'rails/railtie'
require 'webpack/rails/helper'

module Webpack
  class Railtie < ::Rails::Railtie
    config.after_initialize do |app|
      ActiveSupport.on_load(:action_view) do
        include Webpack::Rails::Helper
      end
    end
    rake_tasks do
      load "tasks/webpack.rake"
    end
  end
end
