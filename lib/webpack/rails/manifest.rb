require 'net/http'
require 'uri'

module Webpack
  module Rails
    class Manifest
      class << self
        def manifest
          @manifest ||= if ::Rails.env.production?
            JSON.parse(Net::HTTP.get(URI("http://#{request.host}:3808/webpack/manifest.json")))
          else
            JSON.parse(File.read(::Rails.root.join("public", "webpack", "manifest.json")))
          end
        end

        def asset_path source
          path = manifest["assetsByChunkName"][source]
          if path
            "/webpack/" + path
          else
            raise "Can't find #{source} entry point in manifest.json"
          end
        end
      end
    end
  end
end
