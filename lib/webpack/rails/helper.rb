require 'action_view'
require 'webpack/rails/manifest'

module Webpack
  module Rails
    # Asset path helpers for use with webpack
    module Helper
      # Mapping between rails asset type and webpack extension
      EXTENSIONS_MAPPING = {
        stylesheet: :css,
        javascript: :js
      }.freeze

      # Return asset paths for a particular webpack entry point.
      #
      # Response may either be full URLs (eg http://localhost/...) if the dev server
      # is in use or a host-relative URl (eg /webpack/...) if assets are precompiled.
      #
      # Will raise an error if our manifest can't be found or the entry point does
      # not exist.
      def webpack_asset_paths(source, extension: nil)
        return "" unless source.present?

        paths = Webpack::Rails::Manifest.asset_paths(source)
        paths = paths.select { |p| p.ends_with? ".#{extension}" } if extension

        port = ::Rails.configuration.webpack.dev_server.port
        protocol = ::Rails.configuration.webpack.dev_server.https ? 'https' : 'http'

        host = ::Rails.configuration.webpack.dev_server.host
        host = instance_eval(&host) if host.respond_to?(:call)

        if ::Rails.configuration.webpack.dev_server.enabled
          paths.map! do |p|
            "#{protocol}://#{host}:#{port}#{p}"
          end
        end

        paths
      end

      # Support simple include_javascript_tag
      def compute_asset_path(source, options = {})
        webpack_asset_path(source, options) || super(source, options)
      end

      private

      # Returns first webpack asset path that matches source by type
      def webpack_asset_path(source, options)
        sanitized_source = sanitize_source(source)
        extension = EXTENSIONS_MAPPING[options[:type]]
        webpack_asset_paths(sanitized_source, extension: extension).first
      rescue Webpack::Rails::Manifest::EntryPointMissingError
        nil
      end

      # Removes extension from source name
      def sanitize_source(source)
        File.basename(source, File.extname(source))
      end
    end
  end
end
