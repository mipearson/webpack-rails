require 'net/http'
require 'uri'

module Webpack
  module Rails
    class Manifest
      class ManifestLoadError < StandardError
        def initialize(message, orig)
          super "#{message} (original error #{orig})"
        end
      end

      class EntryPointMissingError < StandardError
      end

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

        def asset_paths(source)
          paths = manifest["assetsByChunkName"][source]
          if paths
            # Can be either a string or an array of strings
            [paths].flatten.map do |p|
              "/#{::Rails.configuration.webpack.public_path}/#{p}"
            end
          else
            raise EntryPointMissingError, "Can't find entry point '#{source}' in webpack manifest"
          end
        end

        private

        def load_manifest
          data = if ::Rails.configuration.webpack.dev_server.enabled
            load_dev_server_manifest
          else
            load_static_manifest
          end
          JSON.parse(data)
        end

        def load_dev_server_manifest
          Net::HTTP.get(
            "localhost",
            dev_server_path,
            ::Rails.configuration.webpack.dev_server.port
          )
        rescue => e
          raise ManifestLoadError.new("Could not load manifest from webpack-dev-server at #{dev_server_url} - is it running, and is stats-webpack-plugin loaded?", e)
        end

        def load_static_manifest
          File.read(static_manifest_path)
        rescue => e
          raise ManifestLoadError.new("Could not load compiled manifest from #{static_manifest_path} - have you run `rake webpack:compile`?", e)
        end

        def static_manifest_path
          ::Rails.root.join(
            ::Rails.configuration.webpack.output_dir,
            ::Rails.configuration.webpack.manifest_filename
          )
        end

        def dev_server_path
          "/#{::Rails.configuration.webpack.public_path}/#{::Rails.configuration.webpack.manifest_filename}"
        end

        def dev_server_url
          "http://localhost:#{::Rails.configuration.webpack.dev_server.port}#{dev_server_path}"
        end
      end
    end
  end
end
