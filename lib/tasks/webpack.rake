namespace :webpack do
  desc "Compile webpack bundles"
  task compile: :environment do
    ENV["TARGET"] = 'production'
    manifest = ::Rails.root.join(::Rails.configuration.webpack.manifest_file)
    webpack_bin = ::Rails.root.join(::Rails.configuration.webpack.binary)
    config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)
    FileUtils.mkdir_p File.dirname(manifest)

    unless File.exist?(webpack_bin)
      raise "Can't find our webpack executable at #{webpack_bin} - have you run `npm install`?"
    end

    unless File.exist?(config_file)
      raise "Can't find our webpack config file at #{config_file}"
    end

    sh "#{webpack_bin} --config #{config_file} --json > #{manifest}"
  end
end
