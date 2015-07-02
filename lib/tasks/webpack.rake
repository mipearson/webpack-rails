namespace :webpack do
  desc "Compile webpack bundles in to public/webpack"
  task compile: :environment do
    ENV["TARGET"] = 'production'
    destdir = Rails.root.join("public", "webpack")
    webpack_bin = Rails.root.join("node_modules", ".bin", "webpack")
    FileUtils.mkdir_p destdir

    system "#{webpack_bin} --json > #{destdir}/manifest.json"
  end
end
