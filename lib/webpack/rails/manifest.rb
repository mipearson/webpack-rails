require 'net/http'
require 'uri'

module Webpack
  module Rails
    class Manifest
      class << self
        def manifest
          if ::Rails.configuration.webpack.dev_server.enabled
            # Don't cache if we're in dev server mode, manifest may change ...
            load_manifest
          else
            # ... otherwise cache at class level, as JSON loading/parsing can be expensive
            @manifest ||= load_manifest
          end
        end

        def asset_path source
          path = manifest["assetsByChunkName"][source]
          if path
            "/#{::Rails::configuration.webpack.public_path}/#{path}"
          else
            raise "Can't find entry point '#{source}' in webpack manifest"
          end
        end

        private

        def load_manifest
          data = if ::Rails.configuration.webpack.dev_server.enabled
            Net::HTTP.get("localhost", "/#{::Rails::configuration.webpack.public_path}/#{::Rails::configuration.webpack.manifest_filename}", ::Rails.configuration.webpack.dev_server.port)
          else
            File.read(::Rails.root.join(::Rails.configuration.webpack.output_dir, ::Rails.configuration.webpack.manifest_filename))
          end
          JSON.parse(data)
        end
      end
    end
  end
end
