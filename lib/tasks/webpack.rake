namespace :webpack do
  desc "Compile webpack bundles in to public/webpack"
  task :compile do
    root = File.expand_path("../../..", __FILE__)
    ENV["TARGET"] = 'production'
    destdir = File.join(root, "public", "webpack")
    webpack_bin = File.join(root, "node_modules", ".bin", "webpack")
    FileUtils.mkdir_p destdir

    system "#{webpack_bin} --json > #{destdir}/manifest.json"
  end
end
