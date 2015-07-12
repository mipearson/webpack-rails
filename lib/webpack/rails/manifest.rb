require 'net/http'
require 'uri'

module Webpack
  module Rails
    class Manifest
      class << self
        def manifest
          @manifest ||= load_manifest
        end

        def asset_path source
          path = manifest["assetsByChunkName"][source]
          if path
            "/#{Rails::configuration.webpack.public_path}/#{path}"
          else
            raise "Can't find #{source} entry point in manifest.json"
          end
        end

        private

        def load_manifest
          path = ::Rails.root.join(::Rails.configuration.webpack.manifest_file)
          JSON.parse(File.read(path))
        rescue => e
          raise "Could not load our webpack manifest from #{path} - have you run `rake webpack:compile`? (original error: #{e})"
        end
      end
    end
  end
end
