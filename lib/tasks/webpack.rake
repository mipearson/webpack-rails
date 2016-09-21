namespace :webpack do
  desc "Compile webpack bundles"
  task compile: :environment do
    ENV["TARGET"] = 'production' # TODO: Deprecated, use NODE_ENV instead
    ENV["NODE_ENV"] = 'production'
    webpack_bin = ::Rails.configuration.webpack.binary
    config_file = ::Rails.root.join(::Rails.configuration.webpack.config_file)

    which_webpack_result = `which #{webpack_bin}`.chomp
    which_webpack_status = $CHILD_STATUS
    unless which_webpack_status.success? && which_webpack_result != ""
      warn <<-EOF.strip_heredoc
      Running `which #{webpack_bin}` returned status code #{which_webpack_status.to_i} with output:
      #{which_webpack_status}
      EOF
      raise "Can't find webpack executable at #{webpack_bin.inspect}. Have you run `npm install`?"
    end

    unless File.exist?(config_file)
      raise "Can't find webpack config file at #{config_file}"
    end

    sh "#{webpack_bin} --config #{config_file} --bail"
  end
end
