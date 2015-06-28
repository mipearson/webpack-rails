require 'action_view'

module Webpack
  module Rails
    module Helper
      include ActionView::Helpers::AssetUrlHelper
      include ActionView::Helpers::AssetTagHelper

      def webpack_javascript_include_tag source

        path = if Rails.env.production?
          webpack_manifest_asset_path source
        else
          "http://localhost:3808/webpack/#{source}.js"
        end

        javascript_include_tag path
      end

      def webpack_manifest_asset_path source
        manifest = JSON.parse(File.read(Rails.root.join("public", "webpack", "manifest.json")))

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
