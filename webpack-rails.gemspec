$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "webpack/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "webpack-rails-react"
  s.version     = Webpack::Rails::VERSION
  s.authors     = ["Dave Jugnst"]
  s.email       = ["djungst@gmail.com"]
  s.homepage    = "https://github.com/wdjungst/webpack-rails-react"
  s.summary     = "Webpack / Rails / React"
  s.description = "Production-tested, JavaScript-first tooling to use webpack within your Rails application"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib,example}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2.0"
end
