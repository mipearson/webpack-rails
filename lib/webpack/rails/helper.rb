require 'action_view'

module Webpack
  module Rails
    module Helper
      include ActionView::Helpers::AssetUrlHelper

      def webpack_asset_path source, options={}
        source = source.to_s
        return "" unless source.present?

        if extname = compute_asset_extname(source, options)
          source = "#{source}#{extname}"
        end

        if ::Rails.env.production?
          webpack_manifest_asset_path source
        else
          "http://#{request.host}:3808/webpack/#{source}"
        end
      end

      def webpack_manifest_asset_path source
        manifest = JSON.parse(File.read(::Rails.root.join("public", "webpack", "manifest.json")))

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
