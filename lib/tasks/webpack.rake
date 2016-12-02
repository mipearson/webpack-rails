namespace :webpack do
  desc "Compile webpack bundles"
  task(:compile) do
    ENV["NODE_ENV"] = 'production'
    sh "npm run compile"
  end

  desc "Start webpack dev server"
  task(:serve) { sh "npm run serve" }
end
