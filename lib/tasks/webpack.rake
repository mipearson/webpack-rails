require "English"

namespace :webpack do
  desc "Compile webpack bundles"
  task compile: :environment do
    ENV["TARGET"] = 'production' # TODO: Deprecated, use NODE_ENV instead
    ENV["NODE_ENV"] = 'production'
    webpack_bin = ::Rails.root.join(::Rails.configuration.webpack.binary)
    config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)

    unless File.exist?(webpack_bin)
      raise "Can't find our webpack executable at #{webpack_bin} - have you run `npm install`?"
    end

    unless File.exist?(config_file)
      raise "Can't find our webpack config file at #{config_file}"
    end

    result = `#{webpack_bin} --bail --config #{config_file} 2>&1`
    puts result
    raise result unless $CHILD_STATUS.exitstatus == 0
  end
end
