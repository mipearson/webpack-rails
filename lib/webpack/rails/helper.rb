require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    module Helper
      def webpack_asset_paths source, options={}
        return "" unless source.present?

        paths = Webpack::Rails::Manifest.asset_paths(source)

        if ::Rails.configuration.webpack.dev_server.enabled
          paths.map! do |p|
            "http://localhost:#{::Rails.configuration.webpack.dev_server.port}#{p}"
          end
        end

        paths
      end
    end
  end
end
