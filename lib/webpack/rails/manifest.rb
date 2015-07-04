module Webpack
  module Rails
    class Manifest
      class << self
        def load_manifest
          @manifest = JSON.parse(File.read(::Rails.root.join("public", "webpack", "manifest.json")))
        end

        def asset_path source
          path = @manifest["assetsByChunkName"][source]
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
