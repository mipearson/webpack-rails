require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    module Helper
      include ActionView::Helpers::AssetUrlHelper

      def webpack_asset_path source, options={}
        source = source.to_s
        return "" unless source.present?

        if ::Rails.env.production?
          Webpack::Rails::Manifest.asset_path(source)
        else
          "http://#{request.host}:3808/webpack/#{source}"
        end
      end
    end
  end
end
