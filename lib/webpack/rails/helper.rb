require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    # Asset path helpers for use with webpack
    module Helper
      # Return asset paths for a particular webpack entry point.
      #
      # Response may either be full URLs (eg http://localhost/...) if the dev server
      # is in use or a host-relative URl (eg /webpack/...) if assets are precompiled.
      #
      # Will raise an error if our manifest can't be found or the entry point does
      # not exist.
      def webpack_asset_paths(source)
        return "" unless source.present?

        paths = Webpack::Rails::Manifest.asset_paths(source)
        host = ::Rails.configuration.webpack.dev_server.host
        port = ::Rails.configuration.webpack.dev_server.port

        if ::Rails.configuration.webpack.dev_server.enabled
          paths.map! do |p|
            "//#{host}:#{port}#{p}"
          end
        end

        paths
      end
    end
  end
end
