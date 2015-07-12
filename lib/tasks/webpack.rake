namespace :webpack do
  desc "Compile webpack bundles"
  task compile: :environment do
    ENV["TARGET"] = 'production'
    manifest = ::Rails.root.join(::Rails.configuration.webpack.manifest_file)
    webpack_bin = Rails.root.join(::Rails.configuration.webpack.binary)
    FileUtils.mkdir_p File.dirname(manifest)

    sh "#{webpack_bin} --json > #{manifest}"
  end
end
