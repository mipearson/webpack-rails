require 'action_view'
require 'webpack/rails/react/manifest'

module Webpack
  module Rails
    module React
      # Asset path helpers for use with webpack
      module Helper
        # Return asset paths for a particular webpack entry point.
        #
        # Response may either be full URLs (eg http://localhost/...) if the dev server
        # is in use or a host-relative URl (eg /webpack/...) if assets are precompiled.
        #
        # Will raise an error if our manifest can't be found or the entry point does
        # not exist.
        def webpack_asset_paths(source, extension: nil)
          return "" unless source.present?

          paths = Webpack::Rails::React::Manifest.asset_paths(source)
          paths = paths.select {|p| p.ends_with? ".#{extension}" } if extension

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
end
