require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    module Helper
      include ActionView::Helpers::AssetUrlHelper

      def webpack_asset_paths source, options={}
        source = source.to_s
        return "" unless source.present?

        paths = Webpack::Rails::Manifest.asset_paths(source)

        if ::Rails.configuration.webpack.dev_server.enabled
          paths.map! do |p|
            "http://#{request.host}:#{::Rails.configuration.webpack.dev_server.port}#{p}"
          end
        end

        paths
      end
    end
  end
end
