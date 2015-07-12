require 'net/http'
require 'uri'

module Webpack
  module Rails
    class Manifest
      class << self
        def manifest
          @manifest ||= JSON.parse(File.read(::Rails.root.join(::Rails.configuration.webpack.manifest_file)))
        end

        def asset_path source
          path = manifest["assetsByChunkName"][source]
          if path
            "/#{Rails::config.webpack.public_path}/#{path}"
          else
            raise "Can't find #{source} entry point in manifest.json"
          end
        end
      end
    end
  end
end
