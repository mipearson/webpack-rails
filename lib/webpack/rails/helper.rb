require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    module Helper
      include ActionView::Helpers::AssetUrlHelper

      def webpack_asset_path source, options={}
        source = source.to_s
        return "" unless source.present?

        if ::Rails.configuration.webpack.dev_server.enabled
          "http://#{request.host}:#{::Rails.configuration.webpack.dev_server.port}/#{::Rails.configuration.webpack.public_path}/#{source}"
        else
          Webpack::Rails::Manifest.asset_path(source)
        end
      end
    end
  end
end
